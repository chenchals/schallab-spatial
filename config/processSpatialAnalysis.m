function [ MI ] = processSpatialAnalysis( varargin )
%PROCESSSPATIALANALYSIS Summary of this function goes here
%   Detailed explanation goes here
fileLoc = '/Users/subravcr/jacob-iMac/Users/elseyjg/temp/schalllab-spatial/processed/darwin/2016-02-26a.mat';
sess = load(fileLoc);
fNames = fieldnames(sess);
CONDITIONS = {'contra_targetOnset';'contra_responseOnset';'ipsi_targetOnset';'ipsi_responseOnset'};
conds = fNames(contains(fNames,CONDITIONS));
measureToUseArr = {'sdf Mean'};
% Distance threshold
neighborDistanceStep = 100; % in microns
neighborDists = [2 5 7]; % distances to use
MI = struct();
distanceVec = [0:100:3100];
for ii = 1:numel(measureToUseArr)
    measureToUseStr = measureToUseArr{ii};
    measureToUse = regexprep(measureToUseStr,'[^A-Za-z0-9]','');
    for c = 1:numel(conds)
        cond = conds{c};
        yMatrix = sess.(cond).(measureToUse);
        sdfWin =  sess.(cond).sdfWindow;
        fprintf('Computing moran sa for condition: %s\n',cond);
        for dd = 1:numel(neighborDists)
            [neighborFx, weightMat] = moranHelper(distanceVec, neighborDists(dd)*neighborDistanceStep,'decay');
            MI.(cond)(dd).(measureToUse).sdfWindow = sdfWin;
            MI.(cond)(dd).(measureToUse).neighborFx = neighborFx;
            MI.(cond)(dd).(measureToUse).weightMat = weightMat;
            MI.(cond)(dd).(measureToUse).y = yMatrix;
            tempMoran = arrayfun(@(y) moran(yMatrix(:,y),weightMat,false),1:size(yMatrix,2),'UniformOutput',false)';
            vNames = tempMoran.Properties.VariableNames;
            for v = vNames
               MI = update(MI.(cond)(dd).(measureToUse),v{1},tempMoran);
            end
        end
    end
end

end

function  [obj] = update(obj,varName, moranTable)
    t = cell2mat(cellfun(@(x) x.(varName), moranTable,'UniformOutput',false)');;
    obj.(['local_' varName]) = t(2:end,:);
    obj.(['global_' varName]) = t(1,:);
end



