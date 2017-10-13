function [ nhpClusters, nhpClusterStats ] = aggregateClusters( fileFilter )
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
   thresholdStr = regexprep(num2str(threshold, 'thr_%0.2f'),'\.','_');
   % Algorithm to use for clustering d1 diagonals 
   clusterFun = @clusterIt;

   distFiles = dir(fileFilter);
   [~,nhpName,~] = fileparts(distFiles(1).folder);
     
   nhpOutMatfile = fullfile(distFiles(1).folder,[nhpName 'ClusterStats_' thresholdStr '.mat']);   
   nhpOutExcelfile = fullfile(distFiles(1).folder,[nhpName 'ClusterStats_' thresholdStr '.xlsx']);
   warning('off', 'MATLAB:table:RowsAddedExistingVars' );
   nhpClusters = table();
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
             nhpClusters.session{rowNum,1} = session;
             nhpClusters.condition{rowNum,1} = cond;
             nhpClusters.threshold{rowNum,1} = threshold;
             nhpClusters.([fxName '_clustNo']){rowNum,1} = clustNo;
             nhpClusters.([fxName '_boc']){rowNum,1} = bc;
             nhpClusters.([fxName '_eoc']){rowNum,1} = ec;
             nhpClusters.([fxName '_ecMinusBc']){rowNum,1} = ecMinusBc;
             nhpClusters.channelSpacing{rowNum,1} = info.channelSpacing;
             nhpClusters.clusterSize_um{rowNum,1} = info.channelSpacing * ecMinusBc;
             nhpClusters.distToNextCluster_um{rowNum,1} = info.channelSpacing * d2c;
             nhpClusters.([fxName '_boc_channel']){rowNum,1} = ephysChannelMap(bc);
             % If ec = 31 then it is correlation 
             % between 31st electrode and 32nd electrode
             % nth corr is correlation between nth and (n+1)th
             nhpClusters.([fxName '_eoc_channel']){rowNum,1} = ephysChannelMap(ec+1);
         end
       end
   end
   nhpClusterStats = getClusterStats(nhpClusters,conditions);
   
   % Save analysis work
   save(nhpOutMatfile, 'nhpClusters', 'nhpClusterStats');
   % Write output to excel
   warning('off','MATLAB:xlswrite:AddSheet');
   writetable(nhpClusters, nhpOutExcelfile,'Sheet','nhpClusters');
   writetable(nhpClusterStats, nhpOutExcelfile,'Sheet','nhpClusterStats');
   % Copy excel file to base processed folder
   copyfile(nhpOutExcelfile, [fileparts(fileparts(nhpOutExcelfile)) '/.']) ;
   
end

function [ outStats ] = getClusterStats(inTable, conditions)
   %[a,b] = arrayfun(@(x) deal(x{1}, nanmean(cell2mat(out.clusterSize_um(strmatch(x,out.condition))))), conditions, 'UniformOutput',false)
   %rows for matching condition
   %ros = strmatch(condition,inTable.condition); %#ok<MATCH2>
   % Matcing rows for condition
   conditions{end+1} = 'ipsi|contra';
   if numel(conditions)~= size(conditions,1)
       conditions = transpose(conditions);
   end
   rows = @(x) find(~cellfun(@isempty,regexp(inTable.condition,[x{1} '.*'],'match')));

   [...
       ZZ.condition,...
       ZZ.channelSpacing,...
       ZZ.clusterSizeMean,...
       ZZ.clusterSizeStd,...
       ZZ.distToNextClusterMean,...
       ZZ.distToNextClusterStd,...
       ZZ.totalNoOfClusters ] = arrayfun(@(x) deal(...
       x{1},... %condition
       unique(cell2mat(inTable.channelSpacing(rows(x)))),...
       nanmean(cell2mat(inTable.clusterSize_um(rows(x)))),...
       nanstd(cell2mat(inTable.clusterSize_um(rows(x)))),...
       nanmean(cell2mat(inTable.distToNextCluster_um(rows(x)))),...
       nanstd(cell2mat(inTable.distToNextCluster_um(rows(x)))),...
       numel(rows(x))...
       ), conditions, 'UniformOutput',false); 
   % make it a table
   outStats = struct2table(ZZ);
   
end
