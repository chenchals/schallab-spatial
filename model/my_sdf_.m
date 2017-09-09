function [sdfStruct] = my_sdf_(spkTimes, varargin)
%MY_SDF Create an sdfStruct for gievn input conditions
%   Inputs:
%   spkTimes : 2D matrix
%              A NaN padded numeric matrix [NTrials x MTimestamps]
%              A Cell array of NTrials
%              {[Trial1 timestamps1]...[TrialN timestamps]}
%   trialList : A vector if trialNos. 
%   eventStruct : A structure where fields are eventNames. Each field can be
%                     Vector : [Ntrials] Position of the timestamp is the TrialNo.
%                     Matrix : [TrialNos, timestamps]
%   alignEventName : Event to align spike timestamps. Event name is used to
%                    lookup the event structure.
%                    *REQUIRED* if more than 1 field in eventStruct
%   eventMarkerNames : A cell array of fieldnames in eventStructure. These
%    [optional]      markers are also aligned to the timestamps of
%                    alignEventName
%    comments : A cell array of comments
%   [optional]      
%
%   Usage:
%  [sdfStruct] = my_sdf(spikeTimes, 'trialList', [1 5], 'eventStruct',events,...
%                'alignEventName', 'responseOnset', 'eventMarkerNames',...
%                {'targetOnset' 'fixSpotOn'}, 'comments', {'Cell:Unit01a', 'Hemisphere:Left'})
%  [sdfStruct] = my_sdf(data(1).spikes.spiketimes, 'trialList',[1:10], ...
%                'eventStruct',data(1).events,'alignEventName','responseOnset')
% 
  % Bin width for min / max time: Time axis will be evenly divisible by this
  sdfWindow = (-300:200)';
  kernel = getExpKernel();
  % For histogram binning. extend to kernel size on either side
  hMin  =  min(sdfWindow)-length(kernel);
  hMax  =  max(sdfWindow)+length(kernel);

try
  sdfStruct.date = datetime;
  parseArgs(varargin);
  if isscalar(spkTimes) 
      error('Variable spikeTimes cannot be a scalar');
  end
  
  if isnumeric(spkTimes)
      spikeTimes = mat2SpikeTimes(spkTimes, trialsInRows);
  elseif iscell(spkTimes)
      spikeTimes = cell2SpikeTimes(spkTimes, trialsInRows);
  end
  clear spkTimes;
  
  if isnan(max(spikeTimes(:))) || isnan(min(spikeTimes(:)))
      % no spikes in spike matrix
      sdfStruct.trialNos=[];
      sdfStruct.counts = [];
      sdfStruct.sdf = [];
      sdfStruct.bins = [];
      sdfStruct.cellAnnotations = [];
      sdfStruct.alignedEvents = [];
      return;
  end
   
  if ~isfield(eventStruct, alignEventName)
      error('Align event name is not in events struct');
  end
 
  % Assume trials are in rows
  nTrials = size(spikeTimes,1);  
  alignTimes  =  eventStruct.(alignEventName);
  if isvector(alignTimes)
      alignTimes = alignTimes(:);
  end
  if ~isscalar(alignTimes) &&  ~(numel(alignTimes) == nTrials) 
          error('No of elements in alignTimes must equal number of rows in spikeTimes');
  end
  %Check trialList
  if isempty(trialList)
      error('trialList is required and cannot be empty');
  end
  
  % Use Trial List after all checks
  nTrials = numel(trialList);
  spikeTimes = spikeTimes(trialList,:,:);
  spikeTimes(spikeTimes == 0) = NaN;
  % Align
  alignTimes = alignTimes(trialList); 
  spikeTimes  =  spikeTimes - alignTimes;
  % Align event markers if is cell array
  if iscell(eventMarkerNames) 
      for ii = 1:length(eventMarkerNames)
          eventName = char(eventMarkerNames(ii));
          eventMat = eventStruct.(eventName);
          sdfStruct.alignedEvents.(eventName) = [eventMat(trialList,1) eventMat(trialList,2)-alignTimes]; 
      end
  end
  
  nCells = size(spikeTimes,3);
  sdfStruct.bins = hMin:hMax;
  sdfWindowIndex = arrayfun(@(x) find(sdfStruct.bins==x),sdfWindow);
  for cell = 1: nCells
      % histogram spikes by trial
      cellSpikeTimes = spikeTimes(:,:,cell);
      spikebyTrialCells = mat2cell(cellSpikeTimes, ones(1,nTrials), size(cellSpikeTimes,2));
      [hCounts,~] = cellfun(@(trial) histcounts(trial,hMin:hMax+1), spikebyTrialCells,'UniformOutput',false);
      sdfStruct.counts(:,:,cell) = cell2mat(hCounts);
      % Note: convn works column wise for matrix:
      % So transpose for convn and then transpose back
      temp = convn(sdfStruct.counts(:,:,cell)',kernel,'same')';
      sdfStruct.sdf(:,:,cell) = temp(:,sdfWindowIndex);
      sdfStruct.sdfMean(cell,:) = nanmean(squeeze(sdfStruct.sdf(:,:,cell)));
  end
  if exist('comments','var')
      sdfStruct.comments = comments;
  else
      sdfStruct.comments = {};
  end
  
catch ME
    error('%s\n',ME.message); 
end
end

%% Convolution Kernel based on Post-synaptic potential
function kernel  =  getExpKernel()
   %kernel = pspKernelPaul;
   kernel = pspKernel;
end

function  parseArgs(inArgs)
    argsObj = inputParser;
    argsObj.addParameter('trialList', [], @(x) assert(isnumeric(x),'Value must be a numeric array'));
    argsObj.addParameter('eventStruct', struct(), @(x) assert(isstruct(x),'Value must be a struct'));
    argsObj.addParameter('alignEventName', '', @(x) assert(ischar(x),'Value must be a char array'));
    argsObj.addParameter('eventMarkerNames', cell(''), @(x) assert(iscellstr(x),'Value must be a cell array of strings'));
    argsObj.addParameter('comments', cell(''),@(x) assert(iscellstr(x),'Value must be a cell array of strings'));
    argsObj.addParameter('trialsInRows', true, @(x) assert(islogical(x),'Value must be a logical [true|false]'));
    argsObj.addParameter('multiUnit', true, @(x) assert(islogical(x),'Value must be a logical [true|false]'));
    argsObj.parse(inArgs{:});
    args = argsObj.Results;
    vars = fieldnames(args);
    for i = 1:length(vars)
        assignin('caller',vars{i},args.(vars{i}));
    end
end

function [ outVar ] = mat2SpikeTimes(inVar, trialsInRows)
    if isvector(inVar) % is a vector
        outVar = inVar(:)'; % convert to row vector (singleTrial)
    else % is a matrix
        outVar = inVar;
        if ~trialsInRows
            outVar = inVar';
        end
    end
end

function [ outVar ] = cell2SpikeTimes(inVar, trialsInRows)
    maxSpikes = max(cellfun(@(x) numel(x), inVar(:)));
    if ~trialsInRows
        inVar = inVar';
    end
    nTrials = size(inVar, 1);
    nCells = size(inVar, 2);
    %nan pad
    outVar = nan(nTrials, maxSpikes, nCells);
    for cell = 1 : nCells
        temp = cell2mat(cellfun(@(x) [x', nan(1, maxSpikes-length(x))],...
            inVar(:,cell), 'uniformoutput', false));
        outVar(:,:,cell) = temp;
    end

end


