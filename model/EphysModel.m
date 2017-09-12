classdef (Abstract=true) EphysModel < handle
    
    properties (Access=protected)
        dataSource;
        sourceFile;
        %
        eventVars
        spikeVars
        %
        eventData
        spikeData
        trialList=containers.Map;        
    end
    
    methods (Abstract)
        getEventData(obj, eventNames)
        getSpikeData(obj, varargin)
        getTrialList(obj, varargin)
        %SDF
        getSingleUnitSdf(obj,varargin)
        getMultiUnitSdf(obj,verargin)
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
        function adapter = newEphysModel(sessionType, source)
            % sessionType : recordings from Joule by Pauls has diff.
            % structure
            
            switch lower(sessionType)
                case 'memory'
                    adapter = MemoryTypeModel(source);
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
        
         function [ electrodeMap ] = getElectrodeMap()
            %neuronexusMap = ([9:16,25:32,17:24,1:8]);
            electrodeMap = {'channelMap', [9:16,25:32,17:24,1:8]};
        end
       
    end
    
end




