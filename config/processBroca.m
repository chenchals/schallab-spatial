function [ nhpSessions ] = processBroca()
%PROCESSJOULE Configure Joule sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 

    nhpConfig.nhp = 'broca';
    nhpConfig.nhpSourceDir = '/Users/chenchals/Projects/lab-schall/schalllab-clustering/data/broca';
    nhpConfig.excelFile = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/config/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Br';
    nhpConfig.nhpOutputDir = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/processed/Broca';
    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;  
    
    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of joule source data files as cellstr
%  Uses column name 'filename' ifrom the execl file used for configuration
  sessions = strcat(srcFolder, filesep, regexprep(nhpTable.filename,'''',''));
end
