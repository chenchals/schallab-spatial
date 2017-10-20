%function  [ trialList ] = memTrialSelector(eventData, selectedOutcomes, targetHemifield)
function  [ trialList ] = memTrialSelector(trialOutcome, selectedOutcomes, targetLocation, targetHemifield)

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
%
%    targetHemifield: Logical location of target.
%                 Example: ['all' | 'right' | 'left']
%                 By default 
%                    left includes vertical up 
%                    right includes vertical down
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
    switch targetHemifield
        case 'left'
            targetHemifieldTrials = ...
                (targetAngle >= 135 & targetAngle <= 225);
        case 'right'
            targetHemifieldTrials = ...
                (targetAngle >= 315 & targetAngle <= 360)|...
                (targetAngle >= 0 & targetAngle <= 45);
        case 'all'
            targetHemifieldTrials = ones(size(eventData,1),1);
        otherwise
            error('Argument targetHemifield must be one of {%s}, but was %s',join({'left','right','all'},','),targetHemifield);
    end
    % Selected trials
    trialList = find(outcomeTrials & targetHemifieldTrials);
        
end
