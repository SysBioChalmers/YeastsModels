initCobraToolbox
clc
content = dir('../models');
%modelsTable = table('VariableNames');
modelNames   = [];
modelsImport = [];
modelsSolve  = [];
modelsObj    = [];
modelsGrowth = [];
modelsBioRxn = [];
bioRxnStrs   = {'biomass' 'Biomass' 'BIOMASS' 'growth' 'GROWTH' 'VGRO'};
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
        modelsObj    = [modelsObj;{mObjective}];
        %Search for biomass or growth pseudoreactions
        if isfield(modelStruct,'rxnNames')
           mBioRxn = '';
           j=1;
           while (isempty(mBioRxn) && j<=length(bioRxnStrs))
               bioStr = bioRxnStrs(j);
               x      = find(contains(modelStruct.rxnNames,bioStr),1);
               if ~isempty(x)
                    mBioRxn = modelStruct.rxnNames{x};
                    if isempty(mObjective)
                        %Set found biomass reaction as objective
                        modelStruct = setParam(modelStruct,'obj',x,1);
                        solution    = solveLP(modelStruct);
                    end
               end
               j=j+1;
            end
        end
        modelsBioRxn = [modelsBioRxn;{mBioRxn}];
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
results = table(modelNames,modelsImport,modelsObj,modelsBioRxn,modelsGrowth,modelsSolve);



