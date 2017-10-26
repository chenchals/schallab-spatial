da_k1=load('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160713-144841_probe1.mat');
da_k2=load('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160711-151215_probe1.mat');
doPlot8R(da_k1,da_k1.session,{'jet','cool'})
doPlot8R(da_k2,da_k2.session,{'jet','cool'})

plotClustersOnProbe('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160713-144841_probe1.mat')
plotClustersOnProbe('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_4/Init_SetUp-160711-151215_probe1.mat')
[clust,clustDist] = aggregateClusters('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_1/*.mat')