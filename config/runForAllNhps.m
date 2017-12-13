% run process for all nhps
addpath(genpath('/Users/subravcr/Projects/lab-schall/schalllab-spatial'));
tic
% run base processing for all files
% rsquared matrices are NOT generated
% sdf, sdfMean, sdfMeanZtr are generated
processBroca;
processDarwin;
processDarwinK;
processGauss;
processHelmholtz;
processJoule;

toc