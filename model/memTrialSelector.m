%function  [ trialList ] = memTrialSelector(eventData, selectedOutcomes, targetHemifield)
function  [ trialList ] = memTrialSelector(trialOutcome, selectedOutcomes, targetLocation, selectedLocation, varargin)

% function  [trialList] = memTrialSelector(eventData, selectedOutcomes, targetHemifield)
%    Inputs:
%    eventData: A structure where fields are eventNames.
%               Each field is a vector of timestamps [nTrials x 1 double].
%               or
%               Each field is a cell array of strings {nTrials x 1 cell}.
%
%    selectedOutcomes: A cell array of strings. Each string is the outcome to
%                   include. There strings must be from
%                   fieldnames(eventData)
%                  Example: {'all',
%                            'saccToTarget',
%                            'targetHoldAbort', 
%                            'distractorHoldAbort',
%                            'fixationAbort', 
%                            'saccadeAbort'
%                            }
% position and angle assignment
%      ____________________
%     |  135 |  90  |   45 |
%     |  (7) |  (0) |  (1) |
%     |______|______|______|
%     |  180 |      |   0  |
%     |  (6) |  *   |  (2) |
%     |______|______|______|
%     |  225 |  270 |  315 |
%     |  (5) |  (4) |  (3) |
%     |______|______|______|
% Logical index of trials with specified hemisphere preference for target
%
%    targetHemifield: Logical location of target.
%                 Example: 
%                    left : {[135 180 225]}
%                    right : {[45 0 315]}
%                    for grouping by target location:
%                    {[0 360] 45 90 135 180 225 270 315}
%
%% Validate input
    
%% Compute indices for trial selection
    % Logical index of trials with specified outcome(s)
    if find(contains(selectedOutcomes, 'all'))
        outcomeTrials = ones(size(trialOutcome,1),1);
    else
        outcomeTrials = contains(trialOutcome, selectedOutcomes);
    end
    % Negative angles = clockwise (0=-360, -90, -180, -270)
    % Positive angles = counter clockConvert (0=360, 90, 180, 270)
    % Convert all angle to be positive
    targetAngle = targetLocation;
    targetAngle(targetAngle < 0) = targetAngle(targetAngle < 0) + 360;
    
    if length(varargin)==2
        taskType = upper(varargin{1});
        selectedTaskType = upper(varargin{2});        
        % logical & of selected criteria
        trialList = cellfun(@(x) find(outcomeTrials ...
            & ismember(targetAngle,x) ...
            & ismember(upper(taskType),upper(selectedTaskType))),...
            selectedLocation,'UniformOutput',false);
    else
        % logical & of selected criteria
        trialList = cellfun(@(x) find(outcomeTrials ...
            & ismember(targetAngle,x)), ...
            selectedLocation,'UniformOutput',false);
    end
            
end
