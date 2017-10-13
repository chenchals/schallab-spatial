% run process for all nhps
tic
processBroca;
processDarwin;
processDarwinK;whos
processGauss;
processHelmholtz;
processJoule;
% run aggregation for all
baseProcessedDir = '/Volumes/schalllab/Users/Chenchal/clustering/processed/';
aggregateClusters([baseProcessedDir 'broca/bp*.mat']);
aggregateClusters([baseProcessedDir 'darwin/20*.mat']);
aggregateClusters([baseProcessedDir 'darwink/Init*.mat']);
aggregateClusters([baseProcessedDir 'gauss/20*.mat']);
aggregateClusters([baseProcessedDir 'helmholtz/20*.mat']);
aggregateClusters([baseProcessedDir 'joule/jp*.mat']);
% Copy excel files to base dir


toc