clear; clc;

% Budowa wspólnego datasetu z plików .mat (NASA)

matFiles = {'B0005.mat','B0006.mat','B0007.mat','B0018.mat'};
outFile  = 'dataset_all.xlsx';

numericFields = string.empty(1,0);
batteries = cell(size(matFiles));

for f = 1:numel(matFiles)
    S = load(matFiles{f});
    rootNames = fieldnames(S);
    B = S.(rootNames{1});

    assert(isfield(B,'cycle'), 'Brak pola "cycle" w %s', matFiles{f});
    C = B.cycle(:);
    batteries{f} = C;


    for i = 1:numel(C)
        if ~isDischarge(C(i)) || ~isfield(C(i),'data'), continue; end
        fn = fieldnames(C(i).data);
        for k = 1:numel(fn)
            if isnumeric(C(i).data.(fn{k}))
                numericFields(end+1) = string(fn{k}); %#ok<SAGROW>
            end
        end
    end
end

numericFields = unique(numericFields);

rows = [];

for f = 1:numel(matFiles)
    [~,bn,~] = fileparts(matFiles{f});
    C = batteries{f};

    dis_idx = 0;
    discharge_map = nan(numel(C),1);
    for i = 1:numel(C)
        if isDischarge(C(i))
            dis_idx = dis_idx + 1;
            discharge_map(i) = dis_idx;
        end
    end

    for i = 1:numel(C)
        if ~isDischarge(C(i)), continue; end

        r = struct();
        r.battery_id           = string(bn);
        r.cycle_index_original = i;             
       
        r.discharge_index = discharge_map(i);

        r.ambient_temperature  = NaN;            

        if isfield(C(i),'ambient_temperature')
            r.ambient_temperature = C(i).ambient_temperature;
        end

        d = struct();
        if isfield(C(i),'data'); d = C(i).data; end

        % agregacja sygnałów
        for k = 1:numel(numericFields)
            fname = char(numericFields(k));

            % Time-ostatnia wartość
            if strcmpi(fname,'Time')
                col = 'Time';
            else
                col = ['mean_' fname];
            end

            if isfield(d, fname) && isnumeric(d.(fname))
                v = double(d.(fname)(:));

        if strcmpi(fname,'Time')
             idxLast = find(~isnan(v), 1, 'last');
        if isempty(idxLast)
             r.(col) = NaN;
        else
             r.(col) = v(idxLast);
        end

        else
             r.(col) = mean(v, 'omitnan');
        end
            else
                r.(col) = NaN;
            end
        end

        rows = [rows; r]; %#ok<SAGROW>
    end
end

if isempty(rows)
    warning('Nie znaleziono cykli "discharge".');
    return;
end

T = struct2table(rows);


baseCols = {'battery_id','discharge_index','cycle_index_original','ambient_temperature'};
meanCols = sort(T.Properties.VariableNames(startsWith(T.Properties.VariableNames,'mean_')));

if ismember('Time', T.Properties.VariableNames)
    T = T(:, [baseCols, {'Time'}, meanCols]);
else
    T = T(:, [baseCols, meanCols]);
end

T = sortrows(T, {'battery_id','discharge_index'});

% Wyznaczenie SOH i RUL 

capCol = 'mean_Capacity';

if ~ismember(capCol, T.Properties.VariableNames)
    warning('Brak pojemności — SOH i RUL ustawione na NaN.');
    T.SOH = nan(height(T),1);
    T.RUL = nan(height(T),1);
else
    T.SOH = nan(height(T),1);
    T.RUL = nan(height(T),1);

    bids = unique(T.battery_id,'stable');
    for b = 1:numel(bids)
        mask = T.battery_id == bids(b);
        Ti   = T(mask,:);

        cap  = Ti.(capCol);

        Nref = min(5, numel(cap));
        Cref = mean(cap(1:Nref), 'omitnan');

        SOH_raw = cap ./ Cref;
        SOH_raw(SOH_raw > 1) = 1;

        SOH_s   = movmedian(SOH_raw, 5, 'omitnan');
        SOH     = cummin(SOH_s);

        last_dis = Ti.discharge_index(end);

        RUL = double(last_dis) - double(Ti.discharge_index);
       
        RUL(RUL < 0) = 0;

        T.SOH(mask) = SOH;
        T.RUL(mask) = RUL;
    end
end


dropCols = {'cycle_index_original','ambient_temperature','mean_Capacity'};
for i = 1:numel(dropCols)
    if ismember(dropCols{i}, T.Properties.VariableNames)
        T(:, dropCols{i}) = [];
    end
end

if isfile(outFile); delete(outFile); end
writetable(T, outFile);

fprintf('Zapisano %d wierszy i %d kolumn do: %s\n', ...
    height(T), width(T), outFile);


function tf = isDischarge(cycle)
    tf = false;
    if isfield(cycle,'type')
        t = cycle.type;
        if isstring(t); t = char(t); end
        if iscell(t) && ~isempty(t); t = t{1}; end
        if ischar(t)
            tf = strcmpi(strtrim(t), 'discharge');
        end
    end
end

