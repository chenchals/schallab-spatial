function nhpClusters = getClustsFromDiag(diag1,threshold,info)

clusterFun = @clusterIt;

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
         if isempty(boc)
             nhpClusters.threshold = [];
             nhpClusters.([fxName '_clustNo']) = [];
             nhpClusters.([fxName '_boc']) = [];
             nhpClusters.([fxName '_eoc']) = [];
             nhpClusters.([fxName '_ecMinusBc']) = [];
             nhpClusters.channelSpacing = [];
             nhpClusters.clusterSize_um = [];
             nhpClusters.distToNextCluster_um = [];
             nhpClusters.([fxName '_boc_channel']) = [];
             % If ec = 31 then it is correlation 
             % between 31st electrode and 32nd electrode
             % nth corr is correlation between nth and (n+1)th
             nhpClusters.([fxName '_eoc_channel']) = [];
             return
         end
         % create table rows for each cluster
         ephysChannelMap = info.ephysChannelMap{1};
         rowNum = 0;
         for clustNo = 1 : numel(boc)
             rowNum = rowNum + 1;
             bc = boc(clustNo);
             ec = eoc(clustNo);
             d2c = dtnc(clustNo);
             ecMinusBc = ec - bc + 1;
             % Create row
             %nhpClusters.session{rowNum,1} = session;
             %nhpClusters.condition{rowNum,1} = cond;
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
         
         %nhpClusterStats = getClusterStats(nhpClusters);
   
         
end

function [ outStats ] = getClusterStats(inTable)
   %[a,b] = arrayfun(@(x) deal(x{1}, nanmean(cell2mat(out.clusterSize_um(strmatch(x,out.condition))))), conditions, 'UniformOutput',false)
   %rows for matching condition
   %ros = strmatch(condition,inTable.condition); %#ok<MATCH2>
   % Matcing rows for condition
   conditions = unique(inTable.condition);
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
