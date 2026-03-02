function PlotModelDiagnostics(Y_true, Y_pred, modelName, targetName)

    idx = (1:numel(Y_true))';

    res = Y_true - Y_pred;

    figure;
    plot(idx, res, 'k', 'LineWidth', 1);
    grid on;
    xlabel('Numer próbki');
    ylabel('Residuum');
    title(sprintf('Residua – %s | %s | Test', modelName, targetName));

    err = abs(res);

    figure;
    plot(idx, err, 'b', 'LineWidth', 1);
    grid on;
    xlabel('Numer próbki');
    ylabel('|Błąd predykcji|');
    title(sprintf('Błędy predykcji – %s | %s | Test', modelName, targetName));

    figure;
    histogram(res, 30);
    grid on;
    xlabel('Residuum');
    ylabel('Liczba próbek');
    title(sprintf('Histogram residuów – %s | %s | Test', modelName, targetName));

    figure;
    scatter(Y_true, Y_pred, 30, 'o');
    hold on;

    minVal = min([Y_true; Y_pred]);
    maxVal = max([Y_true; Y_pred]);
    plot([minVal maxVal], [minVal maxVal], 'r-', 'LineWidth', 1.5);

    grid on;
    xlabel('Wartość rzeczywista');
    ylabel('Wartość przewidywana');
    title(sprintf('Predykcja vs rzeczywistość – %s | %s | Test', modelName, targetName));
    legend('Predykcje', 'Idealne dopasowanie', 'Location', 'best');

end
