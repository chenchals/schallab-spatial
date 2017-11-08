
%% 100 spacing
obs=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_OBS_100'));
boo=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_BOO_100'));

% Hypotheses test:
% H =1 reject H0

[h,p,kst] = kstest2(boo,obs,'alpha',0.05)

%% 150 spacing
obs=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_OBS_150'));
boo=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_BOO_150'));

% Hypotheses test:
% H =1 reject H0

[h,p,kst] = kstest2(boo,obs,'alpha',0.05)

%% 200 spacing
obs=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_OBS_200'));
boo=table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_C_TargOn_BOO_200'));

% Hypotheses test:
% H =1 reject H0

[h,p,kst] = kstest2(boo,obs,'alpha',0.05)