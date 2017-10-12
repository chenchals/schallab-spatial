% run process for all nhps
processBroca;
processDarwin;
processDarwinK;
processGauss;
processHelmholtz;
processJoule;
% run aggregation for all
baseProcessedDir = 'clustering/schalllab-spatial/processed/';
aggregateClusters([baseProcessedDir 'broca/bp*.mat']);
aggregateClusters([baseProcessedDir 'darwin/20*.mat']);
aggregateClusters([baseProcessedDir 'darwink/Init*.mat']);
aggregateClusters([baseProcessedDir 'gauss/20*.mat']);
aggregateClusters([baseProcessedDir 'helmholtz/20*.mat']);
aggregateClusters([baseProcessedDir 'joule/jp*.mat']);

