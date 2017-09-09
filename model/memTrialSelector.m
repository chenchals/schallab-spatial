function  [trialList] = memTrialSelector(eventData, outcomeCellStr, targetHemifield)

% function  [trialList] = mem_trial_selection(subjectID, sessionID, outcomeArray, targetHemifield)
%
% outcomeArray: array of strings indicating the outcomes to include:
%           {'all',
%           'saccToTarget',
%           'targetHoldAbort', 'distractorHoldAbort',
%           'fixationAbort', 'saccadeAbort'
%
%
% targetHemifield: the location of the CORRECT TARGET
%           'all', 'right', or 'left'.
%           By default right includes vertical up, left includes vertical
%           down.
%

%% Validate input
    % Validate eventData
    if isstruct(eventData)
        eventData = struct2table(eventData);
    elseif ~istable(eventData)
        error('Argument eventData must be of class struct or table, but is %s',class(eventData));
    end
    % Validate outcomeCellStr
    if ~iscellstr(outcomeCellStr)
        error('Argument outcomeCellStr must be cell array of strings, but is %s',class(outcomeCellStr));
    else
        verifyCategories(outcomeCellStr, [eventData.trialOutcome;'all'])
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
    if find(contains(outcomeCellStr, 'all'))
        outcomeTrials = ones(size(eventData,1),1);
    else
        outcomeTrials = contains(eventData.trialOutcome, outcomeCellStr);
    end

    % Logical index of trials with specified hemisphere preference for target
    switch targetHemifield
        case 'left'
            targetHemifieldTrials = ...
                (eventData.targAngle > 90 & eventData.targAngle <= 270)|...
                (eventData.targAngle < -90 & eventData.targAngle > -270);
        case 'right'
            targetHemifieldTrials = ...
                (eventData.targAngle > 270 & eventData.targAngle <= 360)|...
                (eventData.targAngle >= 0 & eventData.targAngle < 90)|...
                (eventData.targAngle > -90 & eventData.targAngle < 0)|...
                (eventData.targAngle >= -360 & eventData.targAngle < -270);
        case 'all'
            targetHemifieldTrials = ones(size(eventData,1),1);
        otherwise
            error('Argument targetHemifield must be one of {%s}, but was %s',join({'left','right','all'},','),targetHemifield);
    end
    % Selected trials
    trialList = find(outcomeTrials & targetHemifieldTrials);
end
