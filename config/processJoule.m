function [ nhpSessions ] = processJoule()
%PROCESSJOULE Configure Joule sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 

    nhpConfig.nhp = 'joule';
    nhpConfig.nhpSourceDir = '/Volumes/schalllab';
    nhpConfig.excelFile = 'SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Jo';
    % Write to one dir above the config dir
    [thisDir,~,~] = fileparts(mfilename('fullpath'));    
    nhpConfig.nhpOutputDir = fullfile(thisDir, '../processed', nhpConfig.nhp);  

    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;  
    % DataModel to use
    nhpConfig.dataModelName = DataModel.PAUL_DATA_MODEL;
    nhpConfig.outcome = 'saccToTarget';
    
    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of joule source data files as cellstr
%  Uses column name 'matPath' from the execl file used for configuration
  sessions = strcat(srcFolder, filesep, nhpTable.matPath);
end

