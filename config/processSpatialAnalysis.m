function [ MI ] = processSpatialAnalysis( varargin )
%PROCESSSPATIALANALYSIS Summary of this function goes here
%   Detailed explanation goes here
%    fileLoc = '/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed/darwin/MEM/2016-02-22a_MEM_Q2.mat';
    fileLoc = varargin{1};
    fprintf('Processing file %s\n', fileLoc);
    sess = load(fileLoc);
    [fp, fn, ~] = fileparts(fileLoc);
    oDir = [fp filesep 'moran'];
    oFile = fullfile(oDir,fn);
    %load('session.mat');
    fNames = fieldnames(sess);
    %CONDITIONS responeOset is inferred
    TAREGT_ALIGN_CONDITION = 'targetOnset';
    TARGET_ALIGN_SDF_WINDOW =  [-50 250];
    RESPONSE_ALIGN_SDF_WINDOW = [-150 100];

    RIGHT = [0 45 315 360];
    LEFT = [180 135 225];

    nChannels = numel(sess.info.ephysChannelMap{1});
    channelSpacing = sess.info.channelSpacing;

    % Distance threshold for computing neighborFx
    neighborDistanceStep = 100; % in microns
    neighborDists = [2 5 7]; % distances to use
    distanceVec = [0:channelSpacing:channelSpacing*(nChannels-1)];

    % Infer ipsi contra locations
    ipsi_locations = eval(upper(sess.info.chamberLoc{1}));
    contra_locations = setdiff([RIGHT(:);LEFT(:)]',ipsi_locations);

    tAlign_conds = fNames(contains(fNames,TAREGT_ALIGN_CONDITION));
    rAlign_conds = regexprep(tAlign_conds,'target','response');

    ipsi_index = ~cellfun(@isempty, regexp(tAlign_conds,join(arrayfun(@(x) ['_' num2str(x) '|'],ipsi_locations,'UniformOutput',false),'')));
    contra_index = ~cellfun(@isempty, regexp(tAlign_conds,join(arrayfun(@(x) ['_' num2str(x) '|'],contra_locations,'UniformOutput',false),'')));

    % Gather trimmed Mean SDFs
    tAlign_meanSdfs = arrayfun(@(cond) trimRawSdfCellArray(sess.(cond{1}).sdf,sess.(cond{1}).sdfWindow,TARGET_ALIGN_SDF_WINDOW),tAlign_conds,'UniformOutput',false);
    rAlign_meanSdfs = arrayfun(@(cond) trimRawSdfCellArray(sess.(cond{1}).sdf,sess.(cond{1}).sdfWindow,RESPONSE_ALIGN_SDF_WINDOW),rAlign_conds,'UniformOutput',false);
   
    
    % Gather ipsi, contra trimmed mean SDFs - target aligned
    sdfSize = size(tAlign_meanSdfs{1});
    tAlign_conds{end+1} = 'targetOnset_ipsi';
    tAlign_meanSdfs{end+1} = nanmean(reshape(cell2mat(tAlign_meanSdfs(ipsi_index)),sdfSize(1),sdfSize(2),[]),3);
    tAlign_conds{end+1} = 'targetOnset_contra';
    tAlign_meanSdfs{end+1} = nanmean(reshape(cell2mat(tAlign_meanSdfs(contra_index)),sdfSize(1),sdfSize(2),[]),3);

    % Gather ipsi, contra trimmed mean SDFs - response aligned
    sdfSize = size(rAlign_meanSdfs{1});
    rAlign_conds{end+1} = 'responseOnset_ipsi';
    rAlign_meanSdfs{end+1} = nanmean(reshape(cell2mat(rAlign_meanSdfs(ipsi_index)),sdfSize(1),sdfSize(2),[]),3);
    rAlign_conds{end+1} = 'responseOnset_contra';
    rAlign_meanSdfs{end+1} = nanmean(reshape(cell2mat(rAlign_meanSdfs(contra_index)),sdfSize(1),sdfSize(2),[]),3);
    measureUsed = 'sdfMean';
        
    tAlign_ipsi = tAlign_conds(ipsi_index);
    t_win1 = TARGET_ALIGN_SDF_WINDOW(1);
    t_win2 = TARGET_ALIGN_SDF_WINDOW(2);
    r_win1 = RESPONSE_ALIGN_SDF_WINDOW(1);
    r_win2 = RESPONSE_ALIGN_SDF_WINDOW(2);
    for c = 1:numel(tAlign_conds)
        t_cond = tAlign_conds{c}; % target cond/response cond
        MI.sessionInfo = sess.info; % cant do a parfor with index vars below
        MI.processedDate = datestr(now);

        r_cond = rAlign_conds{c};
        isIpsi = find(contains(tAlign_ipsi,t_cond));

        [t_mat, t_win] = deal(tAlign_meanSdfs{c}, (t_win1:t_win2));
        [r_mat, r_win] = deal(rAlign_meanSdfs{c}, (r_win1:r_win2));

        % correlation for pairs of channels
        fprintf('Computing correlation matrices for condition: %s, %s , and combined\n',t_cond, r_cond);
        t_rsquared = corr(t_mat',t_mat').^2;
        r_rsquared = corr(r_mat',r_mat').^2;
        tr_yMatrix = [t_mat r_mat];
        tr_rsquared = corr(tr_yMatrix',tr_yMatrix').^2;
        fprintf('Computing moran sas');
        for dd = 1:numel(neighborDists)
            neighborD = neighborDists(dd)*neighborDistanceStep;
            [neighborFx, weightMat] = moranHelper(distanceVec, neighborD,'decay');
            for conds = 1:3
                switch conds
                    case 1
                        cond = t_cond;
                        sdfWin = t_win;
                        yMatrix = imputeNaNs(t_mat);
                        sdfMat = t_mat;
                        rsquared = t_rsquared;
                    case 2
                        cond = r_cond;
                        sdfWin = r_win;
                        yMatrix = imputeNaNs(r_mat);
                        sdfMat = r_mat;
                        rsquared = r_rsquared;
                    case 3
                        cond = [t_cond '_' r_cond];
                        sdfWin = {t_win r_win};
                        yMatrix = imputeNaNs(tr_yMatrix);
                        sdfMat = {t_mat r_mat};
                        rsquared = tr_rsquared;
                end
                %fprintf('Computing moran sa for condition: %s, neighborDist: %d\n',cond, neighborD);

                MI.(cond).(measureUsed)(dd).sdfWindow = sdfWin;
                MI.(cond).(measureUsed)(dd).isIpsi = isIpsi;
                MI.(cond).(measureUsed)(dd).sdfMatrix = sdfMat;
                MI.(cond).(measureUsed)(dd).neighborD = neighborD;
                MI.(cond).(measureUsed)(dd).neighborFx = neighborFx;
                MI.(cond).(measureUsed)(dd).weightMat = weightMat;
                MI.(cond).(measureUsed)(dd).y = yMatrix;
                MI.(cond).(measureUsed)(dd).rsquared = rsquared;
                tempMoran = reshapeMoran(arrayfun(@(t) moran(yMatrix(:,t),weightMat,false),1:size(yMatrix,2),'UniformOutput',false)');
                for fn = fieldnames(tempMoran)'
                    MI.(cond).(measureUsed)(dd).(fn{1}) = tempMoran.(fn{1});
                end
            end
        end
    end
    fprintf('Saving moran analysis to location %s\n',oFile);
    if ~exist(oDir,'dir')
        mkdir(oDir);
    end
    save(oFile,'-struct','MI');
end


function [out] = imputeNaNs(in)
  % in the absence of impute function use 0
  out = in;
  out(isnan(out)) = 0;
end

function [ out ] = trimRawSdfCellArray(sdfCellArray, origSdfWin, trimSdfWin)
  sdfWin = trimSdfWin(1):trimSdfWin(2);
  index = find(origSdfWin==sdfWin(1)):find(origSdfWin==sdfWin(end));
  temp = arrayfun(@(x) x{1}(:,index),sdfCellArray,'UniformOutput',false);
  % mean sdf fx from rawSdf
  % cell2mat(cellfun(@(x) nanmean(x,1),temp,'UniformOutput',false));
  out = cell2mat(cellfun(@(x) nanmean(x,1),temp,'UniformOutput',false));;
end

function [yMat, sdfWin] = trimMeanSdfMat(inMat, inSdfWin, trimSdfWin)
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



