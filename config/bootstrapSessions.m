function sessInfo = bootstrapSessions(fileName)

load('jp060n01.mat');
%load(fileName);


nPrint = 50;
bootN = 1000;

% shuffle SDFs for each condition
targetOnsetSdf = contra_targetOnset_right.sdfMean;
targetOnsetSdfShuffles = {};
targetOnsetCorrcoefAll = {};
targetOnsetR_squared = {};
targetOnsetR_squaredNeighbor = {};

responseOnsetSdf = contra_responseOnset_right.sdfMean;
responseOnsetSdfShuffles = {};
responseOnsetCorrcoefAll = {};
responseOnsetR_squared = {};
responseOnsetR_squaredNeighbor = {};

threshold = .5;
printStr = [];
cummTargetClusterSizes = {};
cummResponseClusterSizes = {};

myInfo = info;

for ii = 1:bootN
    if mod(ii,nPrint)==0
        fprintf(repmat('\b',1,length(printStr)));
        printStr = sprintf('Doing iteration %d (of %d)...',ii,bootN);
        fprintf(printStr);
    end
    
    targetOnsetSdfShuffles{ii} = targetOnsetSdf(randperm(size(targetOnsetSdf,1)),:)';
    targetOnsetCorrcoefAll{ii} = corrcoef(targetOnsetSdfShuffles{ii}(:,:));    
    targetOnsetR_squared{ii} = targetOnsetCorrcoefAll{ii}.^2;
    targetOnsetR_squaredNeighbor{ii} = diag(targetOnsetR_squared{ii},1);

    outTarget{ii} = getClustsFromDiag(targetOnsetR_squaredNeighbor{ii},threshold,myInfo);
    cummTargetClusterSizes = cat(1, cummTargetClusterSizes, outTarget{ii}.clusterSize_um);
    

    responseOnsetSdfShuffles{ii} = responseOnsetSdf(randperm(size(responseOnsetSdf,1)),:)';
    responseOnsetCorrcoefAll{ii} = corrcoef(responseOnsetSdfShuffles{ii}(:,:));    
    responseOnsetR_squared{ii} = responseOnsetCorrcoefAll{ii}.^2;
    responseOnsetR_squaredNeighbor{ii} = diag(responseOnsetR_squared{ii},1);   
    
    outResponse{ii} = getClustsFromDiag(responseOnsetR_squaredNeighbor{ii},threshold,myInfo);
    cummResponseClusterSizes = cat(1, cummResponseClusterSizes, outResponse{ii}.clusterSize_um);
    
    
end

sessInfo.targOnSizes = cummTargetClusterSizes;
sessInfo.responseSizes = cummResponseClusterSizes;

fprintf('\n');

%keyboard