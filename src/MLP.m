function [Y_train_pred, Y_valid_pred, Y_test_pred] = MLP( ...
    target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test)

    fprintf('\n====== Multi-Layer Perceptron (MLP, %s) ======\n\n', upper(target));

    if strcmpi(target,'RUL')
        Y_train_t = log1p(Y_train);
        if ~isempty(Y_valid)
            Y_valid_t = log1p(Y_valid);
        else
            Y_valid_t = [];
        end
    else
        Y_train_t = Y_train;
        Y_valid_t = Y_valid;
    end

    % Architektura sieci
    hiddenLayerSizes = [32 16 8];

    if strcmpi(target,'RUL')
    trainFcn = 'trainbr';       % lepsza generalizacja
    else
    trainFcn = 'trainlm';       % szybkie i skuteczne dla SOH
    end

    net = feedforwardnet(hiddenLayerSizes, trainFcn);

    for i = 1:numel(hiddenLayerSizes)
        net.layers{i}.transferFcn = 'tansig';
    end
    net.layers{end}.transferFcn = 'purelin';

    % Early stopping
    if ~isempty(X_valid)
        X_all = [X_train; X_valid];
        Y_all = [Y_train_t; Y_valid_t];

        nTrain = size(X_train,1);
        net.divideFcn = 'divideind';
        net.divideParam.trainInd = 1:nTrain;
        net.divideParam.valInd   = (nTrain+1):size(X_all,1);
        net.divideParam.testInd  = [];
    else
        X_all = X_train;
        Y_all = Y_train_t;
        net.divideFcn = 'dividetrain';
    end

    % Parametry uczenia
    net.trainParam.epochs     = 1500;
    net.trainParam.max_fail   = 20;
    net.trainParam.showWindow = false;

    net = train(net, X_all', Y_all');

    Y_train_out = net(X_train')';
    Y_test_out  = net(X_test')';

    if ~isempty(X_valid)
        Y_valid_out = net(X_valid')';
    else
        Y_valid_out = [];
    end

    if strcmpi(target,'RUL')
        Y_train_pred = expm1(Y_train_out);
        Y_test_pred  = expm1(Y_test_out);
        if ~isempty(Y_valid_out)
            Y_valid_pred = expm1(Y_valid_out);
        else
            Y_valid_pred = [];
        end
    else
        Y_train_pred = Y_train_out;
        Y_test_pred  = Y_test_out;
        Y_valid_pred = Y_valid_out;
    end

    ModelMetrics(Y_train, Y_train_pred, ...
                  Y_valid, Y_valid_pred, ...
                  Y_test,  Y_test_pred);

outDir = fullfile("App","models","_cache");
    if ~exist(outDir,"dir")
        mkdir(outDir);
    end

    S = struct();
    S.model     = net;
    S.modelName = "MLP";
    S.target    = target;

    if strcmpi(target,'RUL')
        S.transform = "log1p_expm1";
    else
        S.transform = "none";
    end

    fname = fullfile(outDir, "cache_MLP_" + upper(string(target)) + ".mat");
    save(fname, "-struct", "S");
end
