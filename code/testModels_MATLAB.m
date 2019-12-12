initCobraToolbox
clc
content = dir('../models');
%modelsTable = table('VariableNames');
modelNames   = [];
modelsImport = [];
modelsSolve  = [];
modelsObj    = [];
modelsGrowth = [];
bioRxnStrs   = {'biomass' 'BIOMASS' 'growth' 'GROWTH' 'VGRO'};
for i=1:length(content)
    file = content(i).name;
    if contains(file,'.xml')
        model = file;
        name  = model(1:(strfind(model,'.xml')-1));
        disp(['Analyzing model: ' name])
        modelNames  = [modelNames; {name}];
        solution    = [];
        mImport     = '';
        modelStruct = [];
        mObjective  = [];
        Growth      = false;
        %try to open with RAVEN
        try
            modelStruct = importModel(['../models/' model]);
        catch
            modelStruct = [];
        end
        if ~isempty(modelStruct)
            mObjective = num2str(find(modelStruct.c,1));
            solution   = solveLP(modelStruct);
            mImport    = 'RAVEN';
        else
            %If RAVEN import was not possiblem try to open with COBRA
            try
                modelStruct = readCbModel(['../models/' model]);
            catch
                modelStruct = [];
            end
            if ~isempty(modelStruct)
                mObjective = num2str(find(modelStruct.c,1));
                solution   = optimizeCbModel(modelStruct);
                mImport    = 'COBRA';
            end
        end
        modelsImport = [modelsImport;{mImport}];
        if isempty(mObjective)
            mObjective = {''};
            %If no objective was found then search for biomass reaction in
            %the model
            if isfield(modelStruct,'rxnNames')
                for bioStr = bioRxnStrs
                    x = find(contains(modelStruct.rxnNames,bioStr),1);
                    if ~isempty(x)
                        mObjective  = {['alt_' num2str(x)]};
                        modelStruct = setParam(modelStruct,'obj',x,1);
                        solution    = solveLP(modelStruct);
                        
                    end
                end
            end
        end
        modelsObj    = [modelsObj;mObjective];
        if isempty(solution)
            modelsSolve  = [modelsSolve; false];
        else
            if solution.f~=0
                Growth  = true;
            end
            modelsSolve  = [modelsSolve; true];
        end
        modelsGrowth = [modelsGrowth;Growth];
    end
end
results = table(modelNames,modelsImport,modelsObj,modelsGrowth,modelsSolve);



