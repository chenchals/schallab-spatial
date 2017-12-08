function [ MI ] = processSpatialAnalysis( varargin )
%PROCESSSPATIALANALYSIS Summary of this function goes here
%   Detailed explanation goes here
fileLoc = '/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed/darwin/MEM/2016-02-22a_MEM_Q2.mat';
sess = load(fileLoc);
fNames = fieldnames(sess);
%CONDITIONS = {'contra_targetOnset';'contra_responseOnset';'ipsi_targetOnset';'ipsi_responseOnset'};
TAREGT_ALIGN_CONDITION = 'targetOnset';
TARGET_ALIGN_SDF_WINDOW =  [-50 250];
RESPONSE_ALIGN_SDF_WINDOW = [-150 100];
target_conds = fNames(contains(fNames,TAREGT_ALIGN_CONDITION));

measureToUseArr = {'sdf Mean Ztr'};
% Distance threshold
neighborDistanceStep = 100; % in microns
neighborDists = [2 5 7]; % distances to use
MI = struct();
distanceVec = [0:100:3100];
MI.sessionInfo = sess.info;
MI.processedDate = datestr(now);
for ii = 1:numel(measureToUseArr)
    measureToUseStr = measureToUseArr{ii};
    measureToUse = regexprep(measureToUseStr,'[^A-Za-z0-9]','');
    for c = 1:numel(target_conds)
        t_cond = target_conds{c}; % target cond/response cond
        r_cond = regexprep(t_cond,'target','response');
        [t_yMatrix, t_sdfWin] = trimSdfMat(sess.(t_cond).(measureToUse),sess.(t_cond).sdfWindow,TARGET_ALIGN_SDF_WINDOW);
        [r_yMatrix, r_sdfWin] = trimSdfMat(sess.(r_cond).(measureToUse),sess.(r_cond).sdfWindow,RESPONSE_ALIGN_SDF_WINDOW);
        
        % correlation for pairs of channels
        fprintf('Computing correlation matrix for condition: %s\n',t_cond);
        t_rsquared = corr(t_yMatrix',t_yMatrix').^2;
        r_rsquared = corr(r_yMatrix',r_yMatrix').^2;
        tr_yMatrix = [t_yMatrix r_yMatrix]; 
        tr_rsquared = corr(tr_yMatrix',tr_yMatrix').^2;
        fprintf('Computing moran sa for condition: %s\n',t_cond);
        for dd = 1:numel(neighborDists)
            [neighborFx, weightMat] = moranHelper(distanceVec, neighborDists(dd)*neighborDistanceStep,'decay');
            for conds = 1:3
                switch conds
                    case 1
                        cond = t_cond;
                        sdfWin = t_sdfWin;
                        yMatrix = t_yMatrix;
                        rsquared = t_rsquared;
                    case 2
                        cond = r_cond;
                        sdfWin = r_sdfWin;
                        yMatrix = r_yMatrix;
                        rsquared = r_rsquared;
                    case 3
                        cond = [t_cond r_cond];
                        sdfWin = {t_sdfWin r_sdfWin};
                        yMatrix = tr_yMatrix;
                        rsquared = tr_rsquared;
                end
                MI.(cond)(dd).(measureToUse).sdfWindow = sdfWin;
                MI.(cond)(dd).(measureToUse).neighborFx = neighborFx;
                MI.(cond)(dd).(measureToUse).weightMat = weightMat;
                MI.(cond)(dd).(measureToUse).y = yMatrix;
                MI.(cond)(dd).(measureToUse).rsquared = rsquared;
                tempMoran = reshapeMoran(arrayfun(@(t) moran(yMatrix(:,t),weightMat,false),1:size(yMatrix,2),'UniformOutput',false)');
                for fn = fieldnames(tempMoran)'
                    MI.(cond)(dd).(measureToUse).(fn{1}) = tempMoran.(fn{1});
                end
            end
        end
    end
end

end

function [out] = imputeNaNs(in)
  % in the absence of impute function use 0
  out = in;
  out(isnan(out)) = 0;
end

function [yMat, sdfWin] = trimSdfMat(inMat, inSdfWin, trimSdfWin)
  sdfWin = trimSdfWin(1):trimSdfWin(2);
  yMat = inMat(:,find(inSdfWin==sdfWin(1)):find(inSdfWin==sdfWin(end)));
  % Ipumute all NaNs
  yMat = imputeNaNs(yMat);
end


function  [out] = reshapeMoran(moranTable)
    vNames = moranTable{1}.Properties.VariableNames;
    for v = vNames
        t = cell2mat(cellfun(@(x) x.(v{1}), moranTable,'UniformOutput',false)');;
        out.(['local_' v{1}]) = t(2:end,:);
        out.(['global_' v{1}]) = t(1,:);
    end
end



