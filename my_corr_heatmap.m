function [ data ] = my_corr_heatmap(dataFile,alignEventName, outcome, hemisphere, sdfWindow)
%function my_corr_heatmap(dataRoot, subject, session)
%dataRoot = '/Volumes/schalllab/Users/Chenchal/Jacob/data/';
%subject = 'joule';
%session = 'jp121n01';
%session = 'jp110n01';
%dataFile = fullfile(dataRoot,subject,[session '.mat']);
%sdfWindow = [-100 400];
% Sort trials based on trial type criteria
%alignEventName = 'targOn';
%alignEventName = 'responseOnset';
%outcome = {'saccToTarget'};
%sidename = 'left';
%side = {'right'};

side = hemisphere;

% Max channels and channel map
maxChannels = 32;
neuronexusMap = ([9:16,25:32,17:24,1:8]);

trialVars = {...
    'fixWindowEntered',...
    'targOn',...
    'responseCueOn',...
    'responseOnset',...
    'toneOn',...
    'rewardOn',...
    'trialOutcome',...
    'saccToTargIndex',...
    'targAngle',...
    'saccAngle',...
    };

[~,fileNoExt,~] = fileparts(dataFile);
figureTitle = join({fileNoExt,...
    'outcome',char(join(outcome,',')),...
    'alignEvent',alignEventName,...
    'hemisphere',char(join(side,','))},'-');

%% Read datafile and process
M = EphysModel.newEphysModel('memory',dataFile);
% Read Event data
fprintf('Reading Event Data from file %s\n',dataFile);
eventData = M.getEventData(trialVars);
% Read Spike data
fprintf('Reading Spike Data from file %s\n',dataFile);
spikeData = M.getSpikeData(...
    'spikeIdVar', 'SessionData.spikeUnitArray',...
    'spiketimeVar', 'spikeData',...
    'channelMap', neuronexusMap);

% Compute RTs (why?)
eventData.rt = eventData.responseOnset - eventData.responseCueOn;
% Create Trial list for all trials, just a row index
eventData.iTrial = (1 : size(eventData.trialOutcome,1))';
% Want to get rid of trials that were mistakenly recored with targets at
% the wrong angles (happens sometimes at the beginning of a task session
% recording when the angles were set wrong). For now, sue the criteria that
% a target must have at least 7 trials to considered legitimate
minTrialsPerCondition = 7;
eventData = pruneTrials(eventData.targAngle,minTrialsPerCondition,eventData);
% Select trials
selectedTrials = memTrialSelector(eventData, outcome, side);
% Compute SDF
[sdf, fx]  = spkfun_sdf(spikeData.spiketimes, selectedTrials, eventData, ...
                        alignEventName, sdfWindow, ...
                        spikeData.spikeIdsTable.spikeIds, maxChannels);
% Plot SDFs 
plotSdfs(sdf.multiUnit,sdf.singleUnit,neuronexusMap,figureTitle);

data.eventData = eventData;
data.spikeData = spikeData;
data.trialList = selectedTrials;
data.sdf = sdf;
data.fx = fx;


end
