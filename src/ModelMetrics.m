
function ModelMetrics(Y_train, Y_train_pred, Y_valid, Y_valid_pred, Y_test, Y_test_pred)


    % Metryki - zbiór treningowy
    MAE_train = mean(abs(Y_train - Y_train_pred));
    MSE_train = mean((Y_train - Y_train_pred).^2);
    RMSE_train = sqrt(MSE_train);
    SS_res_train = sum((Y_train - Y_train_pred).^2);
    SS_tot_train = sum((Y_train - mean(Y_train)).^2);
    R2_train = 1 - (SS_res_train / SS_tot_train);

    fprintf('\nMetryki dla zbioru treningowego :\n\n');
    fprintf('R²:   %.4f\n', R2_train);
    fprintf('MAE:  %.4f\n', MAE_train);
    fprintf('MSE:  %.4f\n', MSE_train);
    fprintf('RMSE: %.4f\n\n', RMSE_train);

    % Metryki - zbiór walidacyjny
    MAE_valid = mean(abs(Y_valid - Y_valid_pred));
    MSE_valid = mean((Y_valid - Y_valid_pred).^2);
    RMSE_valid = sqrt(MSE_valid);
    SS_res_valid = sum((Y_valid - Y_valid_pred).^2);
    SS_tot_valid = sum((Y_valid - mean(Y_valid)).^2);
    R2_valid = 1 - (SS_res_valid / SS_tot_valid);

    fprintf('\nMetryki dla zbioru walidacyjnego :\n\n');
    fprintf('R²:   %.4f (%.2f%%)\n', R2_valid, R2_valid*100);
    fprintf('MAE:  %.4f\n', MAE_valid);
    fprintf('MSE:  %.4f\n', MSE_valid);
    fprintf('RMSE: %.4f\n', RMSE_valid);

    idx_val = (Y_valid ~= 0);
    if any(idx_val)
        MAPE_valid = mean(abs((Y_valid(idx_val) - Y_valid_pred(idx_val)) ./ Y_valid(idx_val))) * 100;
    else
        MAPE_valid = NaN;
    end
    SMAPE_valid = mean(abs(Y_valid - Y_valid_pred) ./ ((Y_valid + Y_valid_pred) / 2)) * 100;

    fprintf('MAPE: %.2f%%\n', MAPE_valid);
    fprintf('SMAPE: %.2f%%\n\n', SMAPE_valid);

    %Metryki - zbiór testowy
    MAE_test = mean(abs(Y_test - Y_test_pred));
    MSE_test = mean((Y_test - Y_test_pred).^2);
    RMSE_test = sqrt(MSE_test);
    SS_res_test = sum((Y_test - Y_test_pred).^2);
    SS_tot_test = sum((Y_test - mean(Y_test)).^2);
    R2_test = 1 - (SS_res_test / SS_tot_test);

    fprintf('\nMetryki dla zbioru testowego :\n\n');
    fprintf('R²:   %.4f (%.2f%%)\n', R2_test, R2_test*100);
    fprintf('MAE:  %.4f\n', MAE_test);
    fprintf('MSE:  %.4f\n', MSE_test);
    fprintf('RMSE: %.4f\n', RMSE_test);

    idx_test = (Y_test ~= 0);
    if any(idx_test)
        MAPE = mean(abs((Y_test(idx_test) - Y_test_pred(idx_test)) ./ Y_test(idx_test))) * 100;
    else
        MAPE = NaN;
    end
    SMAPE = mean(abs(Y_test - Y_test_pred) ./ ((Y_test + Y_test_pred) / 2)) * 100;

    fprintf('MAPE: %.2f%%\n', MAPE);
    fprintf('SMAPE: %.2f%%\n\n', SMAPE);

end

