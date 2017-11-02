function [] = processBroca()
%PROCESSBROCA Configure Broca sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 
    processedDir = '/mnt/teba/Users/Chenchal/clustering_window1/processed';
    nhpConfig.nhpSourceDir = '/mnt/teba';
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
    % Specify conditions to for creating multiSdf
    %condition{x} = {alignOnEventName, TargetLeftOrRight, sdfWindow}
    nhpConfig.conditions{1} = {'targetOnset', {[0 360] 45 90 135 180 225 270 315}, [-50 300]};
    nhpConfig.conditions{2} = {'responseOnset', {[0 360] 45 90 135 180 225 270 315}, [-300 50]};
    % only one tyep of measue for now
    nhpConfig.distancesToCompute = {'correlation'};
    nhpConfig.minTrialsPerCondition = 7;

    processSessionsByLocation(nhpConfig);

end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of broca source data files as cellstr
%  Uses column name 'matPath' from the execl file used for configuration
  sessions = strcat(srcFolder, filesep, nhpTable.matPath);
end
