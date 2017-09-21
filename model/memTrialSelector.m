function  [ trialList ] = memTrialSelector(eventData, selectedOutcomes, targetHemifield)

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
    % Validate eventData
    if isstruct(eventData)
        eventData = struct2table(eventData);
    elseif ~istable(eventData)
        error('Argument eventData must be of class struct or table, but is %s',class(eventData));
    end
    % Validate outcomeCellStr
    if ~iscellstr(selectedOutcomes)
        error('Argument outcomeCellStr must be cell array of strings, but is %s',class(selectedOutcomes));
    else
        verifyCategories(selectedOutcomes, [eventData.trialOutcome;'all'])
    end
    % Validate targetHemifield
    if iscellstr(targetHemifield) && numel(targetHemifield)==1
        targetHemifield = targetHemifield{1};
    elseif ~ischar(targetHemifield)
        error('Argument targetHemifield, if cell string, must contain only 1 element, but has %d elements',numel(targetHemifield));
    end
    verifyCategories({targetHemifield}, {'left';'right';'all'});
    
%% Compute indices for trial selection

    % Logical index of trials with specified outcome(s)
    if find(contains(selectedOutcomes, 'all'))
        outcomeTrials = ones(size(eventData,1),1);
    else
        outcomeTrials = contains(eventData.trialOutcome, selectedOutcomes);
    end
    % Negative angles = clockwise (0=-360, -90, -180, -270)
    % Positive angles = counter clockConvert (0=360, 90, 180, 270)
    % Convert all angle to be positive
    targetAngle = eventData.targAngle;
    targetAngle(targetAngle < 0) = targetAngle(targetAngle < 0) + 360;
    % Logical index of trials with specified hemisphere preference for target
    switch targetHemifield
        case 'left'
            targetHemifieldTrials = ...
                (targetAngle > 90 & targetAngle <= 270);
        case 'right'
            targetHemifieldTrials = ...
                (targetAngle > 270 & targetAngle <= 360)|...
                (targetAngle >= 0 & targetAngle < 90);
        case 'all'
            targetHemifieldTrials = ones(size(eventData,1),1);
        otherwise
            error('Argument targetHemifield must be one of {%s}, but was %s',join({'left','right','all'},','),targetHemifield);
    end
    % Selected trials
    trialList = find(outcomeTrials & targetHemifieldTrials);
        
end
