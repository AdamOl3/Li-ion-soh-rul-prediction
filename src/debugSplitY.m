function debugSplitY(target, Ytr, Yval, Yte)

    fprintf('\n================ DEBUG SPLIT (%s) ================\n', upper(target));

    printStats('TRAIN', Ytr);
    printStats('VALID', Yval);
    printStats('TEST',  Yte);

    if strcmpi(target,'RUL')
        printRULinfo('TRAIN', Ytr);
        printRULinfo('VALID', Yval);
        printRULinfo('TEST',  Yte);
    end

    fprintf('=================================================\n\n');
end

function printStats(name, y)
    y = y(:);
    N = numel(y);
    mn = min(y);
    q1 = quantile(y,0.25);
    md = median(y);
    q3 = quantile(y,0.75);
    mx = max(y);
    fprintf('%s: N=%3d, min=%7.3f, Q1=%7.3f, med=%7.3f, Q3=%7.3f, max=%7.3f\n', ...
        name, N, mn, q1, md, q3, mx);
end

function printRULinfo(name, y)
    y = y(:);
    N = numel(y);
    if N==0, return; end
    p0  = 100*mean(y==0);
    p1  = 100*mean(y<=1);
    p10 = 100*mean(y<=10);
    fprintf('%s: RUL==0: %.1f%%, RUL<=1: %.1f%%, RUL<=10: %.1f%%\n', ...
        name, p0, p1, p10);
end
