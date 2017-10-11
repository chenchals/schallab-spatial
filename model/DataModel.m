classdef (Abstract=true) DataModel < handle
    
    properties (Constant)
        PAUL_DATA_MODEL = 'DataModelPaul';
        WOLF_DATA_MODEL = 'DataModelWolf';
        KALEB_DATA_MODEL = 'DataModelKaleb';        
    end
    
    properties (Access=protected)
        dataSource;
        sourceFile;
        %
        eventVars
        spikeVars
        channelMap
        %
        eventData
        spikeData
        trialList        
    end
    
    methods (Abstract)
        getEventData(obj, varargin)
        getSpikeData(obj, varargin)
        getTrialList(obj, varargin)
    end
    
    methods (Access = public)
        % Close file handles?
                % GETSINGLEUNITSDF
        function [ sdf ] = getSingleUnitSdf(obj, selectedTrials, alignEventName, sdfWindow)
            sdf = getSdf(obj, selectedTrials, alignEventName, sdfWindow, false);
            % Ordering singleUnits by channelMap is not implemented
        end
        
        % GETMULTIUNITSDF
        function [ sdf, sdfOrdered ] = getMultiUnitSdf(obj, selectedTrials, alignEventName, sdfWindow)
            sdf = getSdf(obj, selectedTrials, alignEventName, sdfWindow, true);
            sdfOrdered = orderSdfByChannelMap(sdf, getChannelMap(obj));
        end
        
        % GETCHANNELMAP
        function [ channelMap ] = getChannelMap(obj)
            channelMap = obj.channelMap;
        end
        
    end
    
    methods (Access = protected)
        function []  =  checkFileExists(obj)
            % all data is in a single file
            if ischar(obj.dataSource)
                if ~exist(obj.dataSource,'file')
                    throw(MException('DataModel:checkFileExists', sprintf('File not found %s ',obj.dataSource)));
                end
                % all data is in a multiple files. One cell per file
            elseif iscellstr(obj.dataSource)
                if sum(~cellfun(@exist, obj.dataSource))
                    throw(MException('DataModel:checkFileExists',...
                        sprintf('Files that does not exist:\n %s',...
                        sprintf('%s\n',obj.dataSource{~cellfun(@exist, obj.dataSource)}))));
                end
            else
                throw(MException('DataModel:checkFileExists', 'source must be either char or cellstr'));
            end
        end
        
        function [ sdf ] = getSdf(obj, selectedTrials, alignEventName, sdfWindow, singleOrMultiFlag)
            spikeTimes = obj.getSpikeData().spikeTimes;
            events = obj.getEventData();
            spikeIds = obj.getSpikeData().spikeIdsTable.spikeIds;
            %maxChannels = max(getChannelMap(obj));
            chMap = getChannelMap(obj);
            sdf = spkfun_sdf(spikeTimes, selectedTrials, events, alignEventName, sdfWindow, spikeIds, chMap, singleOrMultiFlag);
            
            % Find population mean and Std of firing rate
            allSdf = cell2mat({sdf.sdf}');
            allSdf = allSdf(:);
            popMean = nanmean(allSdf);
            popStd = nanstd(allSdf);
            % compute z-scores for each cell/channel
            for ii = 1:size(sdf,1)
                sdf(ii).populationMean = popMean;
                sdf(ii).populationStd = popStd;
                sdf(ii).sdfPopulationZscored = (sdf(ii).sdf-popMean)/popStd;
                sdf(ii).sdfPopulationZscoredMean = mean(sdf(ii).sdfPopulationZscored);
            end
        end
    end
    
    methods (Static)
        function [ dataModel ] = newInstance(modelName, source, channelMap)
            switch modelName
                case DataModel.PAUL_DATA_MODEL
                    dataModel = DataModelPaul(source,channelMap);
                case DataModel.WOLF_DATA_MODEL
                    dataModel = DataModelWolf(source,channelMap);
                case DataModel.KALEB_DATA_MODEL
                    dataModel = DataModelKaleb(source,channelMap);
                otherwise
                    throw(MException('DataModel:newInstance', 'Not yet implemented'));
            end
        end
        
        function [ varMap ] = asMap(obj,colonSeparatedKeyVal)
            kv=split(colonSeparatedKeyVal,':');
            varMap=containers.Map({kv{:,1}},{kv{:,2}});
        end
        
    end
end




