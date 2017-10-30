function [] = processBroca()
%PROCESSBROCA Configure Broca sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig
    processedDir = '/Users/elseyjg/temp/schalllab-spatial/processed';
    nhpConfig.nhpSourceDir = '/Volumes/schalllab/';
    nhpConfig.nhp = 'broca';
    nhpConfig.excelFile = 'SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Br';
    % Write to one dir above the config dir
    %[thisDir,~,~] = fileparts(mfilename('fullpath'));    
    nhpConfig.nhpOutputDir = fullfile(processedDir, nhpConfig.nhp);
    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;
    % DataModel to use
    nhpConfig.dataModelName = DataModel.PAUL_DATA_MODEL;
    nhpConfig.outcome = 'saccToTarget';

    processSessions(nhpConfig);

end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of broca source data files as cellstr
%  Uses column name 'matPath' from the execl file used for configuration
  sessions = strcat(srcFolder, filesep, nhpTable.matPath);
end
