da_k1=load('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160713-144841_probe1.mat');
da_k2=load('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160711-151215_probe1.mat');
doPlot8R(da_k1,da_k1.session,{'jet','cool'})
doPlot8R(da_k2,da_k2.session,{'jet','cool'})

plotClustersOnProbe('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160713-144841_probe1.mat')
plotClustersOnProbe('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160711-151215_probe1.mat')
[clust,clustDist] = aggregateClusters('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_1/*.mat')


%% Helmholtz


%% Figure1:
% Make da_k1 and da_k2 : targetOnset [-50  300]
% clustering : 
% 1. use absolute distance not channel number
%    use threshold of absolute distance to call a cluster
% 2. Bum channel: 
% 3. criteria: all channels are clusters to one cluster
% 4. plot of gaps vs criteria Versus plot of clusters size vs criteria

