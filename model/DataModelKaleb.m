classdef DataModelKaleb < DataModel
    %DATAMODELWOLF Model class for reading data from Darwin_K ... recordings
    %  Inputs:
    %    source : A char. Must point to the matlab data file or folder
    %    channelMap : The mapping of cell ID and the channel lovcation on the probe.
    %               For example for neuronexus for Joule the
    %               DSP01a corresponds to position 25 fo the probe.
    %               [9 10 11 12 13 14 15 16 25 26 27 28 29 30 31 32 17 18 19 20 21 22 23 24  1  2  3  4  5  6  7  8]
    %               DSP09 is at one end and DSP08 is at the other end
    %               For Darwin the map the locations [1:32] correspond
    %               linearly to DSP01 to DSP32
    
    % In general uses KiloSOrt, then the model closely fits Wolf's model
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
        
        behaviorFile ='';
        default_error_names = {'False'    'Early'    'Late'    'FixBreak'    'HoldError'    'CatchErrorGo'    'CatchErrorNoGo'};
        
        % These behavioral variables are in Behav.mat/Task structure         
        % build 'trialOutcome' var from Task.error, Task.errorNames, Task.error==0 are Correct trials          
        eventVariables = {
            'targetOnset:StimOnset'
            'responseOnset:SRT'
            'targetLocation:TargetLoc'
            'alignTimes:AlignTimes' % used for aligning the vector of spikeTimes
            'trStarts:trStarts'
            'trEnds:trEnds'
            };
       % Singel units are at ChannelN/UnitN/Spikes.mat
       % The spikeIds are not labelled as DSPNN
       % Build spikeIds and spikeTimes variables
       % spike variable names
        spikeVariables = {
            'spikeIds:'
            'spikeTimes:spkTimes'
            };
       
    end
    
    %Public methods
    methods

        function obj = DataModelKaleb(source, channelMap )           
            obj.dataSource = source;
            obj.checkFileExists;
            obj.behaviorFile = checkAndGetBehaviorFile(obj);
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
            % Task variable from behaviorFile as all the necessary events
            temp = load(obj.behaviorFile,'Task');            
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
            evData = obj.getEventData();
            channelMap = obj.channelMap;
            tempSpk = struct();
            spikeData = struct();
            keys = obj.spikeVars.keys;
            vars = obj.spikeVars.values;
            fprintf('Reading spikeData...');
            for f = 1:numel(obj.dataSource)
                datafile = obj.dataSource{f}; 
                fprintf('#%02d ',channelMap(f));
                for i = 1:numel(keys)
                    key = keys{i};
                    var = vars{i};
                    if strcmp('spikeIds',key)
                        % parse out chanN[a-z] into DSPNN[a-z] from the
                        % datafile filename
                        [~,unitId,~] = fileparts(datafile);
                        temp = regexp(unitId,'chan(\d*)([a-z])$','tokens');
                        tempSpk.(key){f,1}=['DSP' num2str(str2num(temp{1}{1}),'%02d') temp{1}{2}];
                    else % key if spikeTimes
                        tempVars = load(datafile,var);
                        tempVars = tempVars.spkTimes;
                        spikeData.(key)(:,f) = arrayfun(@(x,y,z) tempVars(tempVars>=x & tempVars<=y)-z,...
                           evData.trStarts,evData.trEnds,evData.alignTimes,'UniformOutput',false);
                     end
                end
                clear tempVars
            end % for each unit file
            fprintf('\n');
            spikeData.spikeTimes = cellfun(@(x) transpose(x),spikeData.spikeTimes,'UniformOutput',false)
            %Channel map order for spike Ids 
            for chIndex = 1:numel(channelMap)
                channel = channelMap(chIndex);
                spikeChannels = ~cellfun(@isempty,regexp(tempSpk.spikeIds,num2str(channel,'%02d')));
                tempSpk.unitSortOrder(spikeChannels,1)= channel;
                tempChan.channelIds{chIndex,1} =  ['chan',num2str(channel,'%02d')];
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

       function [ trialOutcome ] = buildTrialOutcomeVar(obj, taskVar) 
            nTrials = size(taskVar.Correct,1);
            trialOutcome = repmat({''},nTrials,1);
            uniqErrIndex=unique(taskVar.error(isfinite(taskVar.error)));
            if isfield(taskVar,'error_names')
                error_names = taskVar.error_names;
            end
            if isempty(error_names)
                error_names = obj.default_error_names;
            end
                        
            for ii = 1:numel(uniqErrIndex)
                outcome = error_names{ii};
                if strcmpi(outcome,'False') % no error
                    outcome = 'Correct';
                end                
                ind = find(taskVar.error==uniqErrIndex(ii));
                trialOutcome(ind) = {outcome}; %#ok<FNDSB>
            end
       end
       
       function [ behaviorFile ] = checkAndGetBehaviorFile(obj)
           % Behavior file, throw exception if file does not exist
           behaviorFile = fullfile(char(...
               cellfun(@char,regexp(obj.dataSource{1},'^(.*-\d*)/.*','tokens'),'UniformOutput',false)...
               ),'Behav.mat');
           
           if ~exist(behaviorFile,'file')
               throw(MException('DataModelKaleb:constructor', sprintf('File not found %s ',behaviorFile)));
           end 
       end
        
    end
end

