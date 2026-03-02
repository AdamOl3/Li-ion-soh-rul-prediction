function [X, Y] = ReadData_RUL()
    % Wczytanie danych
    data = readtable('dataset_all.xlsx', 'Sheet', 'Sheet1');
    
    % Stabilizacja cechy mean_Current_measured (clipping)

    if ismember('mean_Current_measured', data.Properties.VariableNames)
        I = data.mean_Current_measured;
        I_num = I(isfinite(I));

        Q1   = quantile(I_num, 0.25);
        Q3   = quantile(I_num, 0.75);
        IQRx = Q3 - Q1;
        k    = 1.5;                                 % próg Tukeya

        low_thr  = Q1 - k*IQRx;
        high_thr = Q3 + k*IQRx;

        % clipping 

        I_clipped = I;
        I_clipped(I_clipped < low_thr)  = low_thr;
        I_clipped(I_clipped > high_thr) = high_thr;

        n_changed = sum(I ~= I_clipped);
        fprintf('ReadData_RUL: clipped %d outlierów w mean_Current_measured.\n', n_changed);

        data.mean_Current_measured = I_clipped;
    end


    base = {'mean_Current_load','mean_Current_measured', ...
            'mean_Temperature_measured','Time', ...
            'mean_Voltage_load','mean_Voltage_measured'};

    % Cechy pochodne
 

    data.dV = data.mean_Voltage_measured - data.mean_Voltage_load;
    data.IR = data.dV ./ max(1e-6, abs(data.mean_Current_measured));
    data.Vr = data.mean_Voltage_load ./ max(1e-6, data.mean_Voltage_measured);
    
    % Macierz cech i target

    features = [base, {'dV','IR','Vr'}];    

    X = data{:, features};
    Y = data.RUL;

end
