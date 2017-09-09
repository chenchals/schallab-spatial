function [ sdf, z, fx ] = my_corr_heatmap()
%function my_corr_heatmap(dataRoot, subject, session)
dataRoot = '/Volumes/schalllab/Users/Chenchal/Jacob/data/';
subject = 'joule';
session = 'jp121n01';
%session = 'jp110n01';
dataFile = fullfile(dataRoot,subject,[session '.mat']);

plotSdf = 0;
multiUint = 0;

sdfWindow = [-100 400];
maxChannels = 32;

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

M = EphysModel.newEphysModel('memory',dataFile);
eventData = M.getEventData(trialVars);

spikeData = M.getSpikeData(...
    'spikeIdVar', 'SessionData.spikeUnitArray',...
    'spiketimeVar', 'spikeData',...
    'channelMap', [9:16,25:32,17:24,1:8]);
%SessionData1.spikeUnitArray = SessionData1.channelIdsTable.channelIds';

% RTs
eventData.rt = eventData.responseOnset - eventData.responseCueOn;
eventData.iTrial = (1 : size(eventData.trialOutcome,1))';
% Want to get rid of trials that were mistakenly recored with targets at
% the wrong angles (happens sometimes at the beginning of a task session
% recording when the angles were set wrong). For now, sue the criteria that
% a target must have at least 7 trials to considered legitimate
eventData = pruneTrials(eventData.targAngle(~isnan(eventData.targAngle)),7,eventData);

% Sort trials based on trial type criteria
outcome = {'saccToTarget','fixationAbort'};
alignEventName = 'targOn';
%alignEvent = 'responseOnset';
%sidename = 'left';
side = {'right'};

selectedTrials = memTrialSelector(eventData, outcome, side);

[sdf, z, fx]  = spkfun_sdf(spikeData.spiketimes, selectedTrials, eventData, alignEventName, sdfWindow, spikeData.spikeIdsTable.spikeIds, maxChannels);
 
end

function plotMulti(unitArrayNew, sdfAll, epochWindow)
    figure
    set(gcf,'Units','normalized')
    set(gcf,'Position', [0.01,0.01,0.6,0.6])

    for i = 1 : length(unitArrayNew)
        subplot(4,8,i);
        plot(epochWindow,sdfAll(:,i));
        ylims = get(gca,'YLim');
        xlims = get(gca,'XLim');
        text(min(xlims)+10,max(ylims)*.75,sprintf('seq# %d , Unit %s',i,unitArrayNew{i}),'FontSize',8,'FontWeight','bold');
        drawnow
    end
end
