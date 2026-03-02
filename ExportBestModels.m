function ExportBestModels(target)

t = upper(string(target));
outDir = fullfile("App","models");
cacheDir = fullfile(outDir,"_cache");
if ~exist(outDir,"dir"), mkdir(outDir); end

switch t
    case "SOH"
        cacheFile = fullfile(cacheDir,"cache_FNN_SOH.mat");
    case "RUL"
        cacheFile = fullfile(cacheDir,"cache_LSBoost_RUL.mat");
    otherwise
        error("SOH albo RUL");
end

assert(exist(cacheFile,"file")==2, ...
    "Brak cache modelu. Najpierw uruchom projekt.m z target=%s", t);

C = load(cacheFile);

mu  = evalin("base","mu");
sig = evalin("base","sig");

S = struct();
S.target = char(t);
S.modelName = char(C.modelName);
S.model = C.model;
S.mu = mu;
S.sig = sig;
S.meta.transform = C.transform;
S.savedAt = datetime;

fname = fullfile(outDir,"best_model_"+t+".mat");
save(fname,"-struct","S");

d = dir(fname);
fprintf("OK: %s (%d bytes)\n", fname, d.bytes);
end
