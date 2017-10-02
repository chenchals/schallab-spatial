classdef (Abstract=true) EphysModel < handle
    
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
        getSingleUnitSdf(obj,varargin)
        getMultiUnitSdf(obj,varargin)
        getChannelMap(obj)
    end
    
    methods (Access = public)
        % Close file handles?
    end
    
    methods (Access = protected)
        function []  =  checkFileExists(obj)
            % all data is in a single file
            if ischar(obj.dataSource)
                if ~exist(obj.dataSource,'file')
                    throw(MException('EPhysModel:checkFileExists', sprintf('File not found %s ',obj.dataSource)));
                end
                % all data is in a multiple files. One cell per file
            elseif iscellstr(obj.dataSource)
                if sum(~cellfun(@exist, obj.dataSource))
                    throw(MException('EPhysModel:checkFileExists',...
                        sprintf('Files that does not exist:\n %s',...
                        sprintf('%s\n',obj.dataSource{~cellfun(@exist, obj.dataSource)}))));
                end
            else
                throw(MException('EPhysModel:checkFileExists', 'source must be either char or cellstr'));
            end
        end
    end
    
    methods (Static)
        function adapter = newEphysModel(sessionType, source, channelMap)
            % sessionType : recordings from Joule by Pauls has diff.
            % structure
            
            switch lower(sessionType)
                case 'memory'
                    adapter = MemoryTypeModel(source, channelMap);
                case 'darwin'
                    adapter = MemoryTypeModelDa(source, channelMap);
                otherwise
                    error('Type can only be ''memory'' for now...');
            end
        end
        
        function [ eventVars ] = getEventVarNames()

        end
        
        function [ spikeVars ] = getSpikeVarNames()
            spikeVars = {'spikeIdVar','SessionData.spikeUnitArray',...
                         'spiketimeVar','spikeData'};
        end
               
    end
    
end




