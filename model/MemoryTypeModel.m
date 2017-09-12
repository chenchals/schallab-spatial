classdef MemoryTypeModel < EphysModel
    %MEMORYTYPEMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    % dataSource =
    % '/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp121n01.mat'
    %% Public methods
    methods
        %% Constructor
        function obj = MemoryTypeModel(source)
            obj.dataSource = source;
            [~,f,e] = fileparts(source);
            obj.sourceFile = [f e];
            obj.checkFileExists;
        end
        
        %% Abstract Functions implemented
        %% GETEVENTDATA
        function [ eventData ] = getEventData(obj, varargin)
            % Repeated call for eventData returns eventData already read            
            if ~isempty(obj.eventData)
                eventData = obj.eventData;
                return
            end
            % Get event data first time
            if numel(varargin) == 0
                eventNames = EphysModel.getEventVarNames();
            else
                eventNames = varargin{1};
            end
            if iscellstr(eventNames)
                eventData = load(obj.dataSource, eventNames{:});
            elseif ischar(eventNames)
                eventData = load(obj.dataSource, eventNames);
            else
                throw(MException('MemoryTypeModel:getVariables','eventNames must be cellstr or char'));
            end
            obj.eventData = coerceCell2Mat(obj, eventData);
        end
        
        %% GETSPIKEDATA
        function [ spikeData ] = getSpikeData(obj, varargin)
            % Vargars:
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
                if numel(varargin) == 0
                    temp = {EphysModel.getSpikeVarNames(),EphysModel.getElectrodeMap()};
                    args = parseArgs(obj,[temp{:}]);                    
                else
                   args = parseArgs(obj, varargin);
                end
                
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
                channelMap = args.channelMap;
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
        
        %% GETTRILALIST
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
            obj.trialList(key) = memTrialSelector(obj.getEventData(), outcomes, locations);
            selectedTrials = obj.trialList(key);
        end
        
        %% GETSINGLEUNITSDF
        function [ sdf ] = getSingleUnitSdf(obj, selectedTrials, alignEventName, sdfWindow)            
            sdf = getSdf(obj, selectedTrials, alignEventName, sdfWindow, false);
        end
        
        %% GETMULTIUNITSDF
        function [ sdf ] = getMultiUnitSdf(obj, selectedTrials, alignEventName, sdfWindow)
            sdf = getSdf(obj, selectedTrials, alignEventName, sdfWindow, true);
        end
        
        %% GETCHANNELMAP
        function [ channelMap ] = getChannelMap(obj)
            electrodeMap = EphysModel.getElectrodeMap();
            channelMap = electrodeMap{2};
        end
        
    end
    %% Helper Functions
    methods (Access=private)
        
        function [ sdf ] = getSdf(obj, selectedTrials, alignEventName, sdfWindow, singleOrMultiFlag)
            spikeTimes = obj.getSpikeData().spikeTimes;
            eventData = obj.getEventData();
            spikeIds = obj.getSpikeData().spikeIdsTable.spikeIds;
            electrodeMap = EphysModel.getElectrodeMap();
            maxChannels = max(electrodeMap{2});
            sdf = spkfun_sdf(spikeTimes, selectedTrials, eventData, alignEventName, sdfWindow, spikeIds, maxChannels, singleOrMultiFlag);
        end
        
        
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

