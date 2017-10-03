function [ nhpSessions ] = processBroca()
%PROCESSJOULE Configure Joule sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 

    nhpConfig.nhp = 'broca';
    nhpConfig.nhpSourceDir = '/Users/chenchals/Projects/lab-schall/schalllab-clustering';
    nhpConfig.excelFile = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/config/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Br';
    nhpConfig.nhpOutputDir = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/processed/Broca';
    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;  
    % DataModel to use
    nhpConfig.dataModelName = DataModel.PAUL_DATA_MODEL;

    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of broca source data files as cellstr
%  Uses column name 'matPath' from the execl file used for configuration
  sessions = strcat(srcFolder, filesep, nhpTable.matPath);
end
