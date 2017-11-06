% run process for all nhps
addpath(genpath('/Users/subravcr/Projects/lab-schall/schalllab-spatial'));
tic
processDarwinK;
% processBroca;
% processDarwin;
% processGauss;
% processHelmholtz;
% processJoule;
% run aggregation for all
% baseProcessedDir = '/mnt/teba/Users/Chenchal/Jacob/clustering/processed/';
% aggregateClusters([baseProcessedDir 'broca/bp*.mat']);
% aggregateClusters([baseProcessedDir 'darwin/20*.mat']);
% aggregateClusters([baseProcessedDir 'darwink/Init*.mat']);
% aggregateClusters([baseProcessedDir 'gauss/20*.mat']);
% aggregateClusters([baseProcessedDir 'helmholtz/20*.mat']);
% aggregateClusters([baseProcessedDir 'joule/jp*.mat']);
% Copy excel files to base dir


toc