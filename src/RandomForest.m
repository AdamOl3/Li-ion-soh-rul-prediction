function [Y_train_pred, Y_valid_pred, Y_test_pred] = RandomForest( ...
    target, X_train, Y_train, X_valid, Y_valid, X_test, Y_test)

    rng(42); 

    fprintf('\n====== Random Forest (%s) ======\n\n', upper(target));

    useLog = strcmpi(target,'RUL');
    if useLog
        Y_train_t = log1p(Y_train);
    else
        Y_train_t = Y_train;
    end

    % Parametry bazowe lasu
    mtry     = max(1, round(sqrt(size(X_train,2))));
    leafGrid = [5 10 20 50];   
    nTrees   = 400;

    % Strojenie MinLeafSize 
    best = struct('rmse',Inf, 'leaf',NaN, 'rf',[]);

    for i = 1:numel(leafGrid)
        mls = leafGrid(i);

        rf_try = TreeBagger( ...
            nTrees, X_train, Y_train_t, ...
            'Method','regression', ...
            'MinLeafSize', mls, ...
            'NumPredictorsToSample', mtry);

        if useLog
            yv = expm1(predict(rf_try, X_valid));
        else
            yv = predict(rf_try, X_valid);
        end

        rmse_val = sqrt(mean((Y_valid - yv).^2));

        fprintf('RF MinLeaf=%-3d  Val RMSE=%.5f\n', mls, rmse_val);

        if rmse_val < best.rmse
            best.rmse = rmse_val;
            best.leaf = mls;
            best.rf   = rf_try;
        end
    end

    fprintf('>>> Wybrany RF: MinLeaf=%d (Val RMSE=%.5f)\n', ...
        best.leaf, best.rmse);

    rf = best.rf;

    if useLog
        Y_train_pred = expm1(predict(rf, X_train));
        Y_test_pred  = expm1(predict(rf, X_test));
        Y_valid_pred = expm1(predict(rf, X_valid));
    else
        Y_train_pred = predict(rf, X_train);
        Y_test_pred  = predict(rf, X_test);
        Y_valid_pred = predict(rf, X_valid);
    end

    ModelMetrics(Y_train, Y_train_pred, ...
                  Y_valid, Y_valid_pred, ...
                  Y_test,  Y_test_pred);
end


