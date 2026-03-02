function [Y_train_pred, Y_valid_pred, Y_test_pred] = LassoModel( ...
    target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test)

    
    if strcmpi(target,'SOH')

        fprintf('\n====== Lasso Regression (SOH) ======\n');

        Y_train_t = Y_train;

        %Kandydaci lambda 
        lambdaGrid = logspace(-4, 2, 10); 

        best = struct('rmse',Inf, 'lambda',NaN, ...
                      'B',[], 'bias',NaN, 'rmse_train',NaN);

        %Dobór lambda – minimalizacja RMSE na walidacji
        for i = 1:numel(lambdaGrid)
            lambda = lambdaGrid(i);

            [B, FitInfo] = lasso(X_train, Y_train_t, ...
                'Lambda', lambda, ...
                'Standardize', true, ...
                'RelTol', 1e-4, ...
                'MaxIter', 1e5);

            w = B(:,1);
            b = FitInfo.Intercept;

            ytr = X_train*w + b;
            if ~isempty(X_valid)
                yv = X_valid*w + b;
            else
                yv = [];
            end

            rmse_train = sqrt(mean((Y_train - ytr).^2));
            if ~isempty(X_valid)
                rmse_val = sqrt(mean((Y_valid - yv).^2));
            else
                rmse_val = rmse_train;
            end

            fprintf('Lasso(SOH, lambda=%g)  Val RMSE=%.4f  Train RMSE=%.4f\n', ...
                lambda, rmse_val, rmse_train);

            if rmse_val < best.rmse
                best.rmse       = rmse_val;
                best.lambda     = lambda;
                best.B          = w;
                best.bias       = b;
                best.rmse_train = rmse_train;
            end
        end

        fprintf('>>> Wybrany Lasso(SOH): lambda=%g (Val RMSE=%.4f, Train RMSE=%.4f)\n', ...
            best.lambda, best.rmse, best.rmse_train);

   
        nz = nnz(best.B);
        fprintf('    Aktywnych współczynników (≠0): %d / %d\n', nz, numel(best.B));

        w = best.B;
        b = best.bias;

        Y_train_pred = X_train*w + b;
        Y_test_pred  = X_test*w  + b;
        if ~isempty(X_valid)
            Y_valid_pred = X_valid*w + b;
        else
            Y_valid_pred = [];
        end

        ModelMetrics(Y_train, Y_train_pred, ...
                      Y_valid, Y_valid_pred, ...
                      Y_test,  Y_test_pred);
        return;
    end

    if strcmpi(target,'RUL')

        fprintf('\n====== Lasso Regression (RUL, log1p) ======\n');
        Y_train_t = log1p(Y_train);

        lambdaGrid = logspace(-4, 2, 10); 

        best = struct('rmse',Inf, 'lambda',NaN, ...
                      'B',[], 'bias',NaN, 'rmse_train',NaN);

        for i = 1:numel(lambdaGrid)
            lambda = lambdaGrid(i);

            [B, FitInfo] = lasso(X_train, Y_train_t, ...
                'Lambda', lambda, ...
                'Standardize', true, ...
                'RelTol', 1e-4, ...
                'MaxIter', 1e5);

            w = B(:,1);
            b = FitInfo.Intercept;

            ytr = expm1(X_train*w + b);
            if ~isempty(X_valid)
                yv = expm1(X_valid*w + b);
            else
                yv = [];
            end

            rmse_train = sqrt(mean((Y_train - ytr).^2));
            if ~isempty(X_valid)
                rmse_val = sqrt(mean((Y_valid - yv).^2));
            else
                rmse_val = rmse_train;
            end

            fprintf('Lasso(lambda=%g)  Val RMSE=%.4f  Train RMSE=%.4f\n', ...
                lambda, rmse_val, rmse_train);

            if rmse_val < best.rmse
                best.rmse       = rmse_val;
                best.lambda     = lambda;
                best.B          = w;
                best.bias       = b;
                best.rmse_train = rmse_train;
            end
        end

        fprintf('>>> Wybrany Lasso(RUL): lambda=%g (Val RMSE=%.4f, Train RMSE=%.4f)\n', ...
            best.lambda, best.rmse, best.rmse_train);

        nz = nnz(best.B);
        fprintf('    Aktywnych współczynników (≠0): %d / %d\n', nz, numel(best.B));

        w = best.B;
        b = best.bias;

        Y_train_pred = expm1(X_train*w + b);
        Y_test_pred  = expm1(X_test*w  + b);
        if ~isempty(X_valid)
            Y_valid_pred = expm1(X_valid*w + b);
        else
            Y_valid_pred = [];
        end

        ModelMetrics(Y_train, Y_train_pred, ...
                      Y_valid, Y_valid_pred, ...
                      Y_test,  Y_test_pred);
        return;
    end

    error('LassoModel: target musi być "SOH" albo "RUL".');
end
