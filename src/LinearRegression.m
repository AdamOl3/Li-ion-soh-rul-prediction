function [Y_train_pred, Y_valid_pred, Y_test_pred] = LinearRegression( ...
    target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test)

  
    if strcmpi(target,'SOH')

        fprintf('\n====== Linear Regression (OLS, SOH) ======\n');

        mdl = fitlm(X_train, Y_train, 'Intercept', true);

        Y_train_pred = predict(mdl, X_train);
        Y_test_pred  = predict(mdl, X_test);

        if ~isempty(X_valid)
            Y_valid_pred = predict(mdl, X_valid);
        else
            Y_valid_pred = [];
        end

    elseif strcmpi(target,'RUL')

        fprintf('\n====== Linear Regression (OLS, RUL: log1p) ======\n');

        Y_train_t = log1p(Y_train);
        mdl = fitlm(X_train, Y_train_t, 'Intercept', true);

        Y_train_pred = expm1(predict(mdl, X_train));
        Y_test_pred  = expm1(predict(mdl, X_test));

        if ~isempty(X_valid)
            Y_valid_pred = expm1(predict(mdl, X_valid));
        else
            Y_valid_pred = [];
        end

    else
        error('LinearRegression: target musi być "SOH" albo "RUL".');
    end

    ModelMetrics(Y_train, Y_train_pred, ...
                  Y_valid, Y_valid_pred, ...
                  Y_test,  Y_test_pred);
end
