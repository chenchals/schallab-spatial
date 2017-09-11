function [sdfAll] = corr_heatmap(dataRoot, matRoot, subject, session)
%dataRoot = '/Volumes/schalllab/Users/Chenchal/Jacob/data/';matRoot='/Users/subravcr/teba/local/schalllab/Jacob/Clustering-Project/matlab';
multiUint = 1;
epochWindow = [-300 : 200];
dataFile = fullfile(dataRoot,subject,[session '.mat']);
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
    'spikeData',...
    'SessionData',...
    };

trialData = load(dataFile, trialVars{:});
SessionData = trialData.SessionData;
trialData = rmfield(trialData, 'SessionData');
if multiUint
  [SessionData.spikeUnitArray, trialData.spikeData] = convert_to_multiunit(SessionData.spikeUnitArray, trialData.spikeData);
end

trialData = cell_to_mat(trialData);
% RTs
trialData.rt = trialData.responseOnset - trialData.responseCueOn;
trialData.iTrial = (1 : size(trialData.trialOutcome,1))';
% Want to get rid of trials that were mistakenly recored with targets at
% the wrong angles (happens sometimes at the beginning of a task session
% recording when the angles were set wrong). For now, sue the criteria that
% a target must have at least 7 trials to considered legitimate
trialData = pruneTrials(trialData.targAngle(~isnan(trialData.targAngle)),7,trialData);

% Sort trials based on trial type criteria

outcome = {'saccToTarget'};
Kernel.method = 'postsynaptic potential';
Kernel.growth = 1;
Kernel.decay = 20;

sdfAll = [];
%alignEvent = 'targOn';
alignEvent = 'responseOnset';

%sidename = 'left';
sidename = 'right';
side = {sidename};

trialsSide = mem_trial_selection(trialData, outcome, side);
alignSide = trialData.(alignEvent)(trialsSide);

[unitIndex, unitArrayNew] = neuronexus_plexon_mapping(SessionData.spikeUnitArray, 32);

    for i = 1 : length(unitArrayNew)
            iUnitIndex = unitIndex(i);
            [alignedRasters, alignmentIndex] = spike_to_raster(trialData.spikeData(trialsSide, iUnitIndex), alignSide);
            sdfSide = spike_density_function(alignedRasters, Kernel);
            sdfMeanSide = nanmean(sdfSide(:,epochWindow + alignmentIndex), 1);
            sdfAll = [sdfAll ; sdfMeanSide];
    end
sdfAll = fliplr(sdfAll');
unitArrayNew = flipud(unitArrayNew'); 


% Find the correlation coefficient across channels
corrcoefAll = corrcoef(sdfAll(:,:));
r_squared = (corrcoefAll).^2;
r_squared(r_squared < .5) = nan;
imagesc(r_squared);
myMap = colormap('copper');
colormap(flipud(myMap));

% figure dimensions and labels
figure();
set(gcf, 'units', 'norm', 'position', [0 0 .5 .9])

xlabel('Channels (Descending)', 'fontsize', 18);
xticklabels = {'ch32', 'ch31', 'ch30', 'ch29', 'ch28', 'ch27', 'ch26', 'ch25',...
    'ch24', 'ch23', 'ch22', 'ch21', 'ch20', 'ch19', 'ch18', 'ch17',...
    'ch16', 'ch15', 'ch14', 'ch13', 'ch12', 'ch11', 'ch10', 'ch09',...
    'ch08', 'ch07', 'ch06', 'ch05', 'ch04', 'ch03', 'ch02', 'ch01'};
xticks = linspace(1, size(sdfAll', 1), numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', flipud(xticklabels(:)'))

yticklabels = {};
yticks = linspace(1, size(sdfAll', 1), numel(yticklabels));
set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)'))

box off;

% colorbar dimensions and labels
cb = colorbar;
ylabel(cb, 'r^2', 'fontsize', 18);
title(sprintf('%s', session,'  ', alignEvent, '  ', sidename), 'fontsize', 24);

set(cb, 'units', 'norm', 'Position', [.9 .05 .02 .9],  'fontsize', 14);

% window dimensions
currentaxis = gca;
set(currentaxis, 'Position', [.0 .05 .9 .9]);
end