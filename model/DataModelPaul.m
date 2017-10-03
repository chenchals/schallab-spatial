classdef DataModelPaul < DataModel
    %DATAMODELPAUL Model class for reading data from Joule, Broca recordings
    %  Inputs:
    %    source : A char. Must point to the matlab data file or folder
    %    channelMap : The mapping of cell ID and the channel lovcation on the probe.
    %               For example for neuronexus for Joule the
    %               DSP01a corresponds to position 25 fo the probe.
    %               [9 10 11 12 13 14 15 16 25 26 27 28 29 30 31 32 17 18 19 20 21 22 23 24  1  2  3  4  5  6  7  8]
    %               DSP09 is at one end and DSP08 is at the other end
    %               For Darwin the map the locations [1:32] correspond
    %               linearly to DSP01 to DSP32
    
    %  f='data/Joule/jp054n01.mat';chMap=[8, 7, 6, 5, 4, 3, 2, 1, 24, 23, 22, 21, 20, 19, 18, 17, 32, 31, 30, 29, 28, 27, 26, 25, 16, 15, 14, 13, 12, 11, 10, 9]';
    % m=JouleModel(f,chMap)
    
    properties (Access=private)
                 
        eventVariables = {
            'targetOnset:targOn'
            'responseOnset:responseOnset'
            'targetLocation:targAngle'
            'trialOutcome:trialOutcome'
            };       
        
        spikeVariables = {
            'spikeIdVar', 'SessionData.spikeUnitArray',...
            'spiketimeVar', 'spikeData'
            };

    end
    
    %Public methods
    methods

        function obj = DataModelPaul(source, channelMap )     
            
            obj.dataSource = source;
            obj.checkFileExists;
            obj.trialList = containers.Map;
            
            obj.eventVars = DataModel.asMap(obj, obj.eventVariables);
            obj.spikeVars = obj.spikeVariables;
                       
            assert(isnumeric(channelMap) || numel(channelMap) > 1,...
                'Input channelMap but be a numeric vector');
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
            for i=1:numel(keys)
                temp = load(obj.dataSource, vars{i});
                eventData.(keys{i}) = temp.(vars{i});
                clear temp
            end
            obj.eventData = coerceCell2Mat(obj, eventData);
        end
        
        %% GETSPIKEDATA
        function [ spikeData ] = getSpikeData(obj)
            %getSpikeData(obj, varargin)
            %    spikeIdPattern : For mat file with vars DSP01a, DSP09b
            %    spikeIdVar : Spike IDs are in a variable: SessionData.spikeUnitArray
            %    spiketimeVar : A cell array of { nTrials x nUnits}
            %    channelMap : Linear mapping of channels.
            %
            % Usage:
            % [ out ] = obj.getSpikeData(...
            %           'spikeIdVar', 'SessionData.spikeUnitArray',...
            %           'spiketimeVar', 'spikeData',...
            %           'channelMap', [9:16,25:32,17:24,1:8])
            
            
            % Repeated call for spikeData returns spikeData already read
            if ~isempty(obj.spikeData)
                spikeData = obj.spikeData;
                return
            end
            
            % Get spike data first time
            try
               args = parseArgs(obj,obj.spikeVars);
               
                if ~isempty(args.spikeIdPattern)
                    throw(MException('MemoryTypeModel:getSpikeData','Not yet implemented for spikeIdPattern'));
                elseif ~isempty(args.spikeIdVar)
                    if ~contains(who('-file',obj.dataSource),args.spiketimeVar)
                        throw(MException('MemoryTypeModel:getSpikeData',...
                            sprintf('Spike data variable [ %s ] does not exist  in file %s',...
                            args.spiketimeVar,obj.dataSource)));
                    end
                    % spiketimes
                    t = load(obj.dataSource,args.spiketimeVar);
                    spikeData.spikeTimes = t.(args.spiketimeVar);
                    clear t
                    % spikeIds - in a struct variable
                    v = cellstr(split(args.spikeIdVar,'.'));
                    s = load(obj.dataSource,v{1});
                    s = s.(v{1});
                    tempSpk.spikeIds = s.(v{2});
                    clear s v
                else
                    throw(MException('MemoryTypeModel:getSpikeData','Unknown process to get spikeData'));
                end
                tempSpk.spikeIds =tempSpk.spikeIds';
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
                
            catch ME
                msg = [ME.message, char(10), char(10), help('MemoryTypeModel.getSpikeData') ];
                error('MemoryTypeModel:getSpikeData', msg);
            end
            
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
        
        function [ vars ] = coerceCell2Mat(obj,vars)
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
        
        function [ args ] = parseArgs(obj,inArgs)
            argsObj = inputParser;
            argsObj.addParameter('spikeIdPattern', '', @(x) assert(ischar(x),'Value must be a char array'));
            argsObj.addParameter('spikeIdVar', '', @(x) assert(ischar(x),'Value must be a char array'));
            argsObj.addParameter('spiketimeVar', '', @(x) assert(ischar(x),'Value must be a char array'));
            argsObj.addParameter('channelMap', [], @(x) assert(isnumeric(x),'Value must be a vector of channel numbers'));
            argsObj.parse(inArgs{:});
            args = argsObj.Results;
        end
        
    end
end

