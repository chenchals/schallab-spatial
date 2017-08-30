classdef (Abstract=true) EphysModel < handle
    
    properties (Access=protected)
        dataSource;
        sourceFile;
        variablesMap=containers.Map;
    end
    
    methods (Abstract)
        getEventData(obj, eventNames)
        getSpikeData(obj, varargin)
        getTrialList(obj, varargin)
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
    end
    
end




