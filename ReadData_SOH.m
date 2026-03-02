function [X, Y] = ReadData_SOH()
 
    data = readtable('dataset_all.xlsx', 'Sheet', 'Sheet1');

    features = {'mean_Current_load','mean_Current_measured', ...
                'mean_Temperature_measured','Time', ...
                'mean_Voltage_load','mean_Voltage_measured'};

    X = data{:, features};
    Y = data.SOH;
end
