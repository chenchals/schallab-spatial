% Establish working environment and and matlab paths

% Which computer are you on?
if isdir('/Volumes/HD-1/Users/paulmiddlebrooks/')
    projectRoot = '/Volumes/HD-1/Users/paulmiddlebrooks/memory_guided_saccades';
elseif isdir('/Volumes/Macintosh HD/Users/elseyjg/')
    projectRoot = '/Volumes/Macintosh HD/Users/elseyjg/Memory-Guided-Saccade-Project';    
else
    disp('You need to add another condition or the file path is wrong.')
end

% create paths for data and src/matlab
dataRoot = fullfile(projectRoot, 'data');
matRoot = fullfile(projectRoot, 'src/matlab');

% add/generate paths for different data folders 
addpath(genpath(matRoot));
addpath(genpath(fullfile(matRoot,'behavior')));
addpath(genpath(fullfile(matRoot,'mem')));
addpath(genpath(fullfile(matRoot,'neural')));
addpath(genpath(fullfile(matRoot,'plotting')));

% Make this project directory your working directory
cd(matRoot);

% Open a Data File

% declare subject for session list
subject = 'joule';

% Open the list of memory guided saccade sessions
fid = fopen(fullfile(dataRoot,subject, ['mem_sessions_',subject,'.csv']));

% Headers for data type
nCol = 5;
formatSpec = '%s';
mHeader = textscan(fid, formatSpec, nCol, 'Delimiter', ',');

% All data corresponding to each header.
%   Delimiter - indicates character used to separate values
%   TreatAsEmpty - placeholder text for empty value
mData = textscan(fid, '%s %s %d %d %d', 'Delimiter', ',','TreatAsEmpty',{'NA','na'});

% declare variables with data
sessionList     = mData{1};
hemisphereList  = mData{2};
neuronLogical   = logical(mData{3});
lfpLogical      = mData{4}; 
eegLogical      = mData{5};

% Extract only sessions with spike data
sessionList = sessionList(neuronLogical);
epochWindow = [-300 : 200];


% Begin for loop for all sessions

% session row/rows
sessionInd = 11;
session = sessionList{sessionInd};

[trialData, SessionData] = load_data(subject, session, mem_min_vars, 1);


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
r_threshold = .5;
corrcoefAll = corrcoef(sdfAll(:,:));
r_squared = (corrcoefAll).^2;
r_squared(r_squared < r_threshold) = 0; % changed from nan to 0 for logical indexing 8/25 meeting
r_squared(r_squared >= r_threshold) = 1;

% initialize some variables
% 
% clusters = struct();
% clusters.logical = clustersLogical;
% clusters.space = clustersSpace
% get r^2 for only pairs of neighboring channels
r_squaredNeighbor = diag(r_squared,1);


% Find the values that determine possibility of clustering
rLeft = r_squaredNeighbor';
rCenter = r_squaredNeighbor';
rRight = fliplr(r_squaredNeighbor');
% Define number of columns to average
AVG_COLS = 3;
% Dimension over which to average
DIM = 2; % Columns
% Use filter to calculate the moving average across EVERY combination of columns
r_moving_avgLeft = filter(ones(1,AVG_COLS)/AVG_COLS,1,rLeft,[],DIM);
r_moving_avgCenter = movmean(rCenter, 3, 'Endpoints', 0);
r_moving_avgRight = filter(ones(1,AVG_COLS)/AVG_COLS,1,rRight,[],DIM);
r_moving_avgRight = fliplr(r_moving_avgRight);

%r_moving_avgCenter = r_moving_avgLeft(:,AVG_COLS:AVG_COLS:end)


r_norm = r_squaredNeighbor'/3;
r_moving_sum = r_moving_avgLeft + r_moving_avgCenter + r_moving_avgRight + r_norm;

threshold = 1.666;
r_moving_sum(r_moving_sum < threshold) = 0; % changed from nan to 0 for logical indexing 8/25 meeting
r_moving_sum(r_moving_sum >= threshold) = 1;

% Measure lengths of stretches of 1's.

cluster_lengths = regionprops(logical(r_moving_sum), 'Area');
% Convert from structure to simple array of lengths.
cluster_lengths_array = [cluster_lengths.Area];
% If you want 0's in between for spatial purposes:
out = zeros(1, 2*length(cluster_lengths_array)+1);
out(2:2:end) = cluster_lengths_array;









% % plot
% barh(fliplr(r_squaredNeighbor));
% title(sprintf('%s', session,'  ', alignEvent, '  ', sidename, '  inter-channel clusters'), 'fontsize', 18);
% 
% set(gcf, 'units', 'norm', 'position', [0 0 .3 .9])
% 
% xticklabels = {};
% xticks = linspace(1, size(sdfAll', 1), numel(xticklabels));
% set(gca, 'XTick', xticks, 'XTickLabel', flipud(xticklabels(:)'))
% 
% yticklabels = {'ch01-ch02', 'ch02-ch03', 'ch03-ch04', 'ch04-ch05', 'ch05-ch06',... 
%     'ch06-ch07', 'ch07-ch08', 'ch08-ch09', 'ch09-ch10', 'ch10-ch11', 'ch11-ch12',...
%     'ch12-ch13', 'ch13-ch14', 'ch14-ch15', 'ch15-ch016', 'ch16-ch17', 'ch17-ch18',...
%     'ch18-ch19', 'ch19-ch20', 'ch20-ch21', 'ch21-ch22', 'ch22-ch23', 'ch23-ch24',...
%     'ch24-ch25', 'ch25-ch26', 'ch26-ch27', 'ch27-ch28', 'ch28-ch29', 'ch29-ch30',...
%     'ch30-ch31', 'ch31-ch32'};
% yticks = linspace(1, size(r_squaredNeighbor', 1), numel(yticklabels));
% set(gca, 'YTick', yticks, 'YTickLabel', flipud(yticklabels(:)'))
% 
% % window dimensions
% currentaxis = gca;
% set(currentaxis, 'Position', [.2 .05 .5 .9]);
