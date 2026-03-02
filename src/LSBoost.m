function [Y_train_pred, Y_valid_pred, Y_test_pred] = LSBoost( ...
    target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test)

    if strcmpi(target,'SOH')

        fprintf('\n====== Gradient Boosting Trees (LSBoost, SOH) ======\n');

        %Konfiguracja drzewa bazowego
        t = templateTree( ...
            'MinLeafSize', 5, ...
            'NumVariablesToSample', max(1, round(sqrt(size(X_train,2)))) );

        gbm = fitrensemble(X_train, Y_train, ...
            'Method', 'LSBoost', ...
            'NumLearningCycles', 600, ...
            'Learners', t, ...
            'LearnRate', 0.05);

        Y_train_pred = predict(gbm, X_train);
        Y_test_pred  = predict(gbm, X_test);

        if ~isempty(X_valid)
            Y_valid_pred = predict(gbm, X_valid);
        else
            Y_valid_pred = [];
        end

    elseif strcmpi(target,'RUL')

        fprintf('\n====== Gradient Boosting Trees (LSBoost, RUL: log1p) ======\n');

        Y_train_t = log1p(Y_train);

        t = templateTree( ...
            'MinLeafSize', 5, ...
            'NumVariablesToSample', max(1, round(sqrt(size(X_train,2)))) );

        gbm = fitrensemble(X_train, Y_train_t, ...
            'Method', 'LSBoost', ...
            'NumLearningCycles', 800, ...
            'Learners', t, ...
            'LearnRate', 0.05);

        Y_train_pred = expm1(predict(gbm, X_train));
        Y_test_pred  = expm1(predict(gbm, X_test));

        if ~isempty(X_valid)
            Y_valid_pred = expm1(predict(gbm, X_valid));
        else
            Y_valid_pred = [];
        end

    else
        error('LSBoost: target musi być "SOH" albo "RUL".');
    end

    ModelMetrics(Y_train, Y_train_pred, ...
                  Y_valid, Y_valid_pred, ...
                  Y_test,  Y_test_pred);

    outDir = fullfile("App","models","_cache");
    if ~exist(outDir,"dir")
        mkdir(outDir);
    end

    S = struct();
    S.model     = gbm;
    S.modelName = "LSBoost";
    S.target    = target;

    if strcmpi(target,'RUL')
        S.transform = "log1p_expm1";
    else
        S.transform = "none";
    end

    fname = fullfile(outDir, "cache_LSBoost_" + upper(string(target)) + ".mat");
    save(fname, "-struct", "S");
end


