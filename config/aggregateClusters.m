function [ out, clusterStats ] = aggregateClusters( fileFilter )
%AGGREGATECLUSTERS Summary of this function goes here
%   Detailed explanation goes here
   % Files for extraating data
   % fileFilter = 'clustering/schalllab-spatial/processed/joule/jp*.mat';
   % Conditions - these are fields  / variable names in the mat file
   % This variable/field is a struct with distance matrix
   conditionsChamberLeft = {
       'ipsi_targetOnset_left'
       'ipsi_responseOnset_left'
       'contra_targetOnset_right'
       'contra_responseOnset_right'
       };
   conditionsChamberRight = {
       'ipsi_targetOnset_right'
       'ipsi_responseOnset_right'
       'contra_targetOnset_left'
       'contra_responseOnset_left'
       };
   % Distance / similarity matrix.  A field in the condition variable
   distMatName = 'rsquared';
   threshold = 0.5;
   
   % Algorithm to use for clustering d1 diagonals 
   clusterFun = @clusterIt;

   distFiles = dir(fileFilter);
   out = table();
   rowNum = 0;
   for jj = 1:numel(distFiles)
       fn = fullfile(distFiles(jj).folder, distFiles(jj).name);
       [~,session,~] = fileparts(fn);
       fprintf('%s\n',session);
       info = load(fn,'info');
       info = info.info;
       conditions = conditionsChamberLeft;
       if strcmp(info.chamberLoc,'right')
           conditions=conditionsChamberRight;
       end     
       temp = load(fn,conditions{:});
       for condIndex = 1:numel(conditions)
         cond = conditions{condIndex};
         diag1 = diag(temp.(cond).(distMatName),1);
         % for cluster funs
         fxName = functiontostring(clusterFun);
         try
             % beginingOfCluster, enfOfCluster, distanceToNextCluster
             [boc, eoc, dtnc] = clusterFun(diag1,threshold);
         catch me
             disp(me);
             boc = [];
             eoc = [];
             dtnc = [];
         end
         % create table rows for each cluster
         ephysChannelMap = info.ephysChannelMap{1};
         for clustNo = 1 : numel(boc)
             rowNum = rowNum + 1;
             bc = boc(clustNo);
             ec = eoc(clustNo);
             d2c = dtnc(clustNo);
             ecMinusBc = ec - bc + 1;
             % Create row
             out.session{rowNum,1} = session;
             out.condition{rowNum,1} = cond;
             out.threshold{rowNum,1} = threshold;
             out.([fxName '_clustNo']){rowNum,1} = clustNo;
             out.([fxName '_boc']){rowNum,1} = bc;
             out.([fxName '_eoc']){rowNum,1} = ec;
             out.([fxName '_ecMinusBc']){rowNum,1} = ecMinusBc;
             out.channelSpacing{rowNum,1} = info.channelSpacing;
             out.clusterSize_um{rowNum,1} = info.channelSpacing * ecMinusBc;
             out.distToNextCluster_um{rowNum,1} = info.channelSpacing * d2c;
             out.([fxName '_boc_channel']){rowNum,1} = ephysChannelMap(bc);
             % If ec = 31 then it is correlation 
             % between 31st electrode and 32nd electrode
             % nth corr is correlation between nth and (n+1)th
             out.([fxName '_eoc_channel']){rowNum,1} = ephysChannelMap(ec+1);
         end
       end
   end
   
   clusterStats.clusterSizeMean = nanmean(cell2mat(out.clusterSize_um));
   clusterStats.clusterSizeStd = nanstd(cell2mat(out.clusterSize_um));
   clusterStats.distToNextClusterMean = nanmean(cell2mat(out.distToNextCluster_um));
   clusterStats.distToNextClusterStd = nanstd(cell2mat(out.distToNextCluster_um));
   clusterStats.totalNoOfClusters = size(out,1);
   
end

