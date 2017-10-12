classdef DataModelWolf < DataModel
    %DATAMODELWOLF Model class for reading data from Darwin_WJ, Gauss, Helmholtz recordings
    %  Inputs:
    %    source : A char. Must point to the matlab data file or folder
    %    channelMap : The mapping of cell ID and the channel lovcation on the probe.
    %               For example for neuronexus for Joule the
    %               DSP01a corresponds to position 25 fo the probe.
    %               [9 10 11 12 13 14 15 16 25 26 27 28 29 30 31 32 17 18 19 20 21 22 23 24  1  2  3  4  5  6  7  8]
    %               DSP09 is at one end and DSP08 is at the other end
    %               For Darwin the map the locations [1:32] correspond
    %               linearly to DSP01 to DSP32
    
    % See PLX_get_paradigm.m (Wolf's code)
    % Line# 237 - line# 239
    % tempoStimOn = PLXin_get_event_time(EV.Target_, t);
    %     
    % plxMat.Task.refresh_offset(t)  = plxMat.Task.StimOnsetToTrial(t) - tempoStimOn;
    % ...
    % Line# 263 - line#277
    % % define stimulus onset as zero
    % %plxMat.Task.Task.SRT       = plxMat.Task.SRT              - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.Saccade         = plxMat.Task.Saccade          - plxMat.Task.StimOnsetToTrial;  % time of saccade relative to trial start
    % plxMat.Task.SaccEnd         = plxMat.Task.SaccEnd          - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.Reward          = plxMat.Task.Reward           - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.Tone            = plxMat.Task.Tone             - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.RewardTone      = plxMat.Task.RewardTone       - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.ErrorTone       = plxMat.Task.ErrorTone        - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.FixSpotOn       = plxMat.Task.FixSpotOn        - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.FixSpotOff      = plxMat.Task.FixSpotOff       - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.StimOnset       = plxMat.Task.StimOnsetToTrial - plxMat.Task.StimOnsetToTrial; % should be all zero aferwards
    % plxMat.Task.FixSpotOnTEMPO  = plxMat.Task.FixSpotOnTEMPO   - plxMat.Task.StimOnsetToTrial;
    % plxMat.Task.FixSpotOffTEMPO = plxMat.Task.FixSpotOffTEMPO  - plxMat.Task.StimOnsetToTrial;
    % 
    % plxMat.Task.SaccDur         = plxMat.Task.SaccEnd          - plxMat.Task.Saccade;
    %     
    %
    % # Line# 383 - line# 398
    % the numerical values that are subtracted are defined in the tempo
    % configuration files. Unfortunately this has to be hard coded and is
    % arbitrary in its definition. Be careful and double check thouroughy.
    %
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
    %    
    % Task.TargetLoc = TargetAngle, 
    
    properties (Access=private)
                 
        eventVariables = {
            'targetOnset:StimOnset'
            'responseOnset:Saccade'
            'targetLocation:TargetLoc'
            };
        % build 'trialOutcome' var from Task.error, Task.errorNames, Task.error==0 are cCorrect trials          
  
        spikeVariables = {
            'spikeIds:DSPname'
            'spikeTimes:spiketimes'
            };

    end
    
    %Public methods
    methods

        function obj = DataModelWolf(source, channelMap )           
            obj.dataSource = source;
            obj.checkFileExists;
            obj.trialList = containers.Map;
            
            obj.eventVars = DataModel.asMap(obj, obj.eventVariables);
            obj.spikeVars =  DataModel.asMap(obj, obj.spikeVariables);
                       
            assert(isnumeric(channelMap) || numel(channelMap) > 1,...
                'Input channelMap must be a numeric vector');
            obj.channelMap =  channelMap;
        end
        
        %% GETEVENTDATA
        function [ eventData ] = getEventData(obj)
            % Repeated call for eventData returns eventData already read .            
            if ~isempty(obj.eventData)
                eventData = obj.eventData;
                return
            end
            keys = obj.eventVars.keys;
            vars = obj.eventVars.values;
            % Task variable as all the necessary events
            % use one of the source files to get task
            behaviorFile = obj.dataSource{1};
            temp = load(behaviorFile,'Task');            
            for i=1:numel(vars)
                eventData.(keys{i}) = temp.Task.(vars{i});

            end
            % Build trialOutcome variable
            eventData.trialOutcome = buildTrialOutcomeVar(obj,temp.Task);
            obj.eventData = coerceCell2Mat(obj, eventData);
            clear temp
        end
        
        %% GETSPIKEDATA
        function [ spikeData ] = getSpikeData(obj)
            %getSpikeData(obj)
            %    spikeIds : SessionData.spikeUnitArray - A cellstr
            %    spiketimes : spikeData - A cell array of { nTrials x nUnits}
            
             % Repeated call for spikeData returns spikeData already read
            if ~isempty(obj.spikeData)
                spikeData = obj.spikeData;
                return
            end
            tempSpk = struct();
            spikeData = struct();
            keys = obj.spikeVars.keys;
            vars = obj.spikeVars.values;
            for f = 1:numel(obj.dataSource)
                datafile = obj.dataSource{f};
                tempVars = load(datafile,vars{:});
                for i = 1:numel(keys)
                    key = keys{i};
                    var = vars{i};
                    if strcmp('spikeIds',key)
                        tempSpk.(key){f,1}=tempVars.(var);
                    else % key if spikeTimes
                        nTrials = size(tempVars.(var),1);
                        for t = 1:nTrials
                            spikeData.(key){t,f}=tempVars.(var)(t,~isnan(tempVars.(var)(t,:)))';
                        end
                     end
                end
                clear tempVars;
            end % for each unit file
            
            %Channel map order for spike Ids
            channelMap = obj.channelMap;
            for ch = 1:max(channelMap)
                channel = channelMap(ch);
                spikeChannels = ~cellfun(@isempty,regexp(tempSpk.spikeIds,num2str(ch,'%02d')));
                tempSpk.unitSortOrder(spikeChannels,1)= channel;
                tempChan.channelIds{ch,1} =  ['chan',num2str(ch,'%02d')];
            end
            tempChan.channelSortOrder(:,1)= channelMap';
            spikeData.spikeIdsTable = struct2table(tempSpk);
            spikeData.channelIdsTable = struct2table(tempChan);
            obj.spikeData = spikeData;
        end
        
        % GETTRILALIST
        function [ selectedTrials ] = getTrialList(obj, selectedOutcomes, targetHemifield)
            %Convert inputs to cellstr
            outcomes = selectedOutcomes;
            if ischar(outcomes)
                outcomes = {outcomes};
            end
            locations = targetHemifield;
            if ischar(locations)
                locations = {locations};
            end
            key = char(join({'outcomes',char(join(outcomes,',')),...
                'locations',char(join(locations,','))},'-'));
            
            if obj.trialList.isKey(key)
                selectedTrials = obj.trialList(key);
                return
            end
            % Get trial list first time
            obj.trialList(key) = memTrialSelector(obj.getEventData().trialOutcome, outcomes,...
                obj.getEventData().targetLocation, targetHemifield);
            selectedTrials = obj.trialList(key);
        end
    end
    %% Helper Functions
    methods (Access=private)
        
        function [ vars ] = coerceCell2Mat(obj,vars) %#ok<INUSL>
            fields = fieldnames(vars);
            for jj=1:numel(fields)
                field = fields{jj};
                if iscell(vars.(field)) && ~iscellstr(vars.(field))
                    maxDim = max(cellfun(@(x) max(size(x)),vars.(field)));
                    if  maxDim == 1 % each value is a scalar
                        vars.(field) = cell2mat(vars.(field));
                    else % May be NaN pad if numeric?
                        % {[1xn1] [1xn2],...[1xnn]} -> diff vector sizes
                        % {[m1xn1] [m2xn2],...mnxnn]} --> diff matrices
                        % {{} {} ...{}}
                    end
                end
            end
        end

       function [ trialOutcome ] = buildTrialOutcomeVar(obj, taskVar) %#ok<INUSL>
            trialOutcome = repmat({''},taskVar.NTrials,1);
            uniqErrIndex=unique(taskVar.error(isfinite(taskVar.error)));
            for ii = 1:numel(uniqErrIndex)
                outcome = taskVar.error_names{ii};
                if strcmpi(outcome,'False') % no error
                    outcome = 'Correct';
                end
                
                ind = find(taskVar.error==uniqErrIndex(ii));
                trialOutcome(ind) = {outcome}; %#ok<FNDSB>
            end
        end
        
    end
end

