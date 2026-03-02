clear;
clc;
rng(42);

target = 'RUL';                 % 'SOH' | 'RUL'
splitType = 'battery';         

test_battery = "B0018";             
val_ratio_battery = 0.20;           
valMode = 'stratified';            

doLinear =  true;
doRF     =  true;
doGBM    =  true;   
doMLP    =  true;
doLasso  =  true;
doMLPM   =  false;

%% 1) Wczytanie danych
switch upper(target)
    case 'SOH'
        [X, Y] = ReadData_SOH();                     
    case 'RUL'
        [X, Y] = ReadData_RUL();                     
    otherwise
        error('target musi być SOH albo RUL');
end

% Usuwanie braków
ok = all(isfinite(X),2) & isfinite(Y);
X = X(ok,:); 
Y = Y(ok);

%% 2) Split Danych 
bid   = [];
sets  = struct();
idX_train = []; idX_valid = []; idX_test = [];

Ttab = readtable('dataset_all.xlsx','Sheet','Sheet1');
assert(ismember('battery_id', Ttab.Properties.VariableNames), ...
           'Brakuje battery_id w dataset_all.xlsx (Sheet1).');
bid_all = string(Ttab.battery_id);
bid = bid_all(ok);
dix =[];
if ismember('discharge_index', Ttab.Properties.VariableNames)
    dix_all = double(Ttab.discharge_index);
    dix = dix_all(ok);
end

args = {'TestBatteries', test_battery, ...
        'ValRatio', val_ratio_battery, ...
        'ValMode',  valMode, ...
        'Verbose',  true};
   
if ~isempty(dix)
    args = [args, {'DischargeIndex', dix}];
end

[X_train, X_valid, X_test, Y_train, Y_valid, Y_test, idX_train,...
    idX_valid, idX_test, sets] = SplitDataBattery( X, Y, bid, args{:});   

%% 3) Standaryzacja 
    
mu  = mean(X_train, 1);
sig = std(X_train, [], 1);
sig(sig == 0) = 1;                          
  
X_train = (X_train - mu) ./ sig;
X_valid = (X_valid - mu) ./ sig;
X_test  = (X_test  - mu) ./ sig;

debugSplitY(target, Y_train, Y_valid, Y_test);
   
%% 4) MODELE

Y_test_pred = [];

if doLinear
    [Y_train_pred, Y_valid_pred, Y_test_pred] = LinearRegression(target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test); 
end

if doRF
    [Y_train_pred, Y_valid_pred, Y_test_pred] = RandomForest(target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test);  
end

if doGBM
    [Y_train_pred, Y_valid_pred, Y_test_pred] = LSBoost(target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test);  
end
if strcmpi(target,'SOH')
   
     PlotModelDiagnostics(Y_test,  Y_test_pred,  'LSBoost', 'SoH');
end

if doMLP
    [Y_train_pred, Y_valid_pred, Y_test_pred] = MLP(target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test);
end
if strcmpi(target,'RUL')
   
     PlotModelDiagnostics(Y_test,  Y_test_pred,  'MLP', 'RUL');
end


if doLasso
    [Y_train_pred, Y_valid_pred, Y_test_pred] = LassoModel(target, ...
        X_train, Y_train, X_valid, Y_valid, X_test, Y_test);
end

if doMLPM
    [Y_train_pred, Y_valid_pred, Y_test_pred] = MLPModel(target, ...
        X_train, Y_train, X_valid, Y_valid, X_test, Y_test);
end



fprintf('\nDONE.\n');


%% 5) Sanity checks
forbidden = {'mean_Capacity','discharge_index','SOH','RUL'};
features_used = {'mean_Current_load','mean_Current_measured', ...
                 'mean_Temperature_measured','Time', ...
                 'mean_Voltage_load','mean_Voltage_measured'};
assert(~any(ismember(forbidden, features_used)), 'W cechach znalazły się kolumny zabronione.');

if isfield(sets,'test') && isfield(sets,'trainval')
    assert(isempty(intersect(sets.trainval, sets.test)), ...
        'Baterie train/val i test nalozyly sie!');
end

ExportBestModels(target);

