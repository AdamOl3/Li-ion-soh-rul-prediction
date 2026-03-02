function [Xtr, Xval, Xte, Ytr, Yval, Yte, idxTr, idxVal, idxTe, sets] = ...
    SplitDataBattery(X, Y, battery_id, varargin)

    p = inputParser;
    addParameter(p,'ValRatio',0.20,@(x)isnumeric(x)&&x>=0&&x<1);
    addParameter(p,'TestBatteries',string.empty,@(s)isstring(s) || iscellstr(s));
    addParameter(p,'ValMode','random',@(s) any(strcmpi(s,{'random','stratified','time'})));
    addParameter(p,'DischargeIndex',[],@(v)isnumeric(v) || isdatetime(v));
    addParameter(p,'Verbose',true,@islogical);
    parse(p,varargin{:});
    opt = p.Results;

    n = size(X,1);
    assert(size(Y,1)==n,'X i Y muszą mieć tyle samo wierszy.');
    bid = string(battery_id(:));
    assert(numel(bid)==n,'battery_id musi mieć długość N.');

    ub = unique(bid,'stable');
    assert(numel(ub)>=2,'Potrzeba >=2 baterii (jedna na test, co najmniej jedna na train/val).');


    if isempty(opt.TestBatteries)
        teSet = ub(end);                                    
    else
        teSet = string(opt.TestBatteries(:));
    end
    
    trvalSet = setdiff(ub, teSet, 'stable');
    idxTe = find(ismember(bid, teSet));
    maskTrVal = ismember(bid, trvalSet);
   
    assert(~isempty(trvalSet),'Brak baterii na train/val.');

    rng(42);

    switch lower(opt.ValMode)

        case 'random'
            idxTrVal = find(maskTrVal);
            nTrVal   = numel(idxTrVal);
            nVal     = max(1, floor(opt.ValRatio * nTrVal));

            perm   = idxTrVal(randperm(nTrVal));
            idxVal = perm(1:nVal);
            idxTr  = perm(nVal+1:end);

        case 'stratified'
            idxVal = []; idxTr = [];
            for b = 1:numel(trvalSet)
                rows_b = find(bid==trvalSet(b));
                n_b    = numel(rows_b);
                nVal_b = max(1, floor(opt.ValRatio * n_b));

                pperm  = rows_b(randperm(n_b));
                idxVal = [idxVal; pperm(1:nVal_b)];       %#ok<AGROW>
                idxTr  = [idxTr;  pperm(nVal_b+1:end)];   %#ok<AGROW>
            end

        case 'time'
            dix = opt.DischargeIndex;
            assert(~isempty(dix) && numel(dix)==n, ...
                'ValMode="time" wymaga DischargeIndex o długości N.');
            dix = double(dix(:));

            idxVal = []; idxTr = [];
            for b = 1:numel(trvalSet)
                rows_b = find(bid==trvalSet(b));
                [~,ord] = sort(dix(rows_b),'ascend');                          
                rows_b  = rows_b(ord);

                n_b    = numel(rows_b);
                nVal_b = max(1, floor(opt.ValRatio * n_b));

                idxVal = [idxVal; rows_b(end-nVal_b+1:end)];                     %#ok<AGROW>
                idxTr  = [idxTr;  rows_b(1:end-nVal_b)];                         %#ok<AGROW>
            end
    end

    % Budowa zbiorów
    
    Xtr = X(idxTr,:);   Ytr = Y(idxTr,:);
    Xval= X(idxVal,:);  Yval= Y(idxVal,:);
    Xte = X(idxTe,:);   Yte = Y(idxTe,:);

    if opt.Verbose
        fprintf('[SplitDataBattery] train/val: %s | val mode: %s | test: %s\n', ...
            strjoin(trvalSet,','), lower(opt.ValMode), strjoin(teSet,','));
        fprintf('N=%d -> train=%d (%.1f%%), val=%d (%.1f%%), test=%d (%.1f%%)\n', ...
            n, numel(idxTr),100*numel(idxTr)/n, numel(idxVal),100*numel(idxVal)/n, numel(idxTe),100*numel(idxTe)/n);
    end

    sets = struct('trainval',trvalSet,'test',teSet,'valmode',lower(opt.ValMode));
end
