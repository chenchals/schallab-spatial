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
            if ~exist(obj.dataSource,'file')
                throw(MException('EPhysModel:checkFileExists', sprintf('File not found %s ',obj.dataSource)));
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
                otherwise
                    error('Type can only be ''memory'' for now...');
            end
        end
        
        function [ eventVars ] = getEventVarNames()
            eventVars = {...
                'fixWindowEntered',...
                'targOn',...
                'responseCueOn',...
                'responseOnset',...
                'toneOn',...
                'rewardOn',...
                'trialOutcome',...
                'saccToTargIndex',...
                'targAngle',...
                'saccAngle',...
                };
        end
        
        function [ spikeVars ] = getSpikeVarNames()
            spikeVars = {'spikeIdVar','SessionData.spikeUnitArray',...
                         'spiketimeVar','spikeData'};
        end
               
    end
    
end




