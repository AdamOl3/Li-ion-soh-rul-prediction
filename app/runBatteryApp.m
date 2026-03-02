function runBatteryApp()
    disp("URUCHOMIONO: Projekt\App\runBatteryApp.m");

    % ŚCIEŻKI
    htmlPath = "C:\Users\aolec\OneDrive\Pulpit\Projekt\App\index.html";
    sohPath  = "C:\Users\aolec\OneDrive\Pulpit\Projekt\App\models\best_model_SOH.mat";
    rulPath  = "C:\Users\aolec\OneDrive\Pulpit\Projekt\App\models\best_model_RUL.mat";
    fisPath  = "C:\Users\aolec\OneDrive\Pulpit\Projekt\Fuzzy\ModelFuzzy3.fis";

    % UI 
    fig = uifigure( ...
        'Name','Battery SOH & RUL Predictor', ...
        'Position',[100 100 1200 750], ...
        'AutoResizeChildren','off');

    h = uihtml(fig, ...
        'HTMLSource', htmlPath, ...
        'Position',[0 0 fig.Position(3) fig.Position(4)]);

    fig.SizeChangedFcn = @(~,~) set(h,'Position',[0 0 fig.Position(3) fig.Position(4)]);

    % Wczytannie modeli
    soh = load(sohPath);  
    rul = load(rulPath);  
    fis = readfis(fisPath);

    disp("SOH model class: " + class(soh.model));
    disp("RUL model class: " + class(rul.model));
    disp("RUL transform: "  + string(rul.meta.transform));

    h.DataChangedFcn = @(src,evt) onHtmlData(src, soh, rul, fis);
end

function onHtmlData(h, soh, rul, fis)

    data = h.Data;
    if isempty(data) || ~strcmp(data.action,'predict')
        return;
    end

    try
        in = data.inputs;

      
        xSOH = [
            in.loadCurrent
            in.measuredCurrent
            in.temperature
            in.time
            in.loadVoltage
            in.measuredVoltage
        ];

        xSOHn  = (xSOH - soh.mu(:)) ./ soh.sig(:);
        sohVal = soh.model(xSOHn);

    
        dV = in.measuredVoltage - in.loadVoltage;
        IR = dV / max(1e-6, abs(in.measuredCurrent));
        Vr = in.loadVoltage / max(1e-6, in.measuredVoltage);

        xRUL = [
            in.loadCurrent
            in.measuredCurrent
            in.temperature
            in.time
            in.loadVoltage
            in.measuredVoltage
            dV
            IR
            Vr
        ];

        xRULn = (xRUL - rul.mu(:)) ./ rul.sig(:);

        % predykcja 
        rulRaw = predict(rul.model, xRULn');

        % transformacja (BO BYŁA W UCZENIU)
        if isfield(rul.meta,'transform') && rul.meta.transform == "log1p_expm1"
            rulVal = expm1(rulRaw);
        else
            rulVal = rulRaw;
        end

        % Fuzzy Logic
         
        sohClamped = min(max(sohVal, 0.5669), 1.0);
        rulClamped = min(max(rulVal, 0), 167);

        condValue = evalfis(fis, [sohClamped rulClamped]);
        [label,msg] = interpretFuzzy(condValue);

        
        % WYJŚCIE DO HTML 
        h.Data = struct( ...
            "action","results", ...
            "soh",        double(sohVal), ...
            "rul",        double(rulVal), ...
            "condValue",  double(condValue), ...
            "condLabel",  label, ...
            "status",     msg );

    catch ME
        disp(getReport(ME,'extended'));
        h.Data = struct( ...
            "action","results", ...
            "soh", NaN, ...
            "rul", NaN, ...
            "condValue", NaN, ...
            "condLabel","BŁĄD", ...
            "status", ME.message );
    end
end

function [label, msg] = interpretFuzzy(v)

    if v >= 0.75
        label = "Dobra";
        msg   = "Kondycja dobra — bateria w dobrej formie. Standardowa eksploatacja.";
    elseif v >= 0.25
        label = "Średnia";
        msg   = "Kondycja średnia — monitoruj regularnie, unikaj skrajnych obciążeń i temperatur.";
    else
        label = "Słaba";
        msg   = "Kondycja słaba — ogranicz obciążenia, rozważ diagnostykę lub wymianę.";
    end
end
