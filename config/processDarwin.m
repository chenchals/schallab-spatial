function [ nhpSessions, nhpConfig ] = processDarwin()
%PROCESSJOULE Configure Darwin (WJ) sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 

    nhpConfig.nhp = 'darwin';
    nhpConfig.nhpSourceDir = '/Volumes/schalllab';
    nhpConfig.excelFile = 'SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Da_WJ';
    % Write to one dir above the config dir
    [thisDir,~,~] = fileparts(mfilename('fullpath'));    
    nhpConfig.nhpOutputDir = fullfile(thisDir, '../processed', nhpConfig.nhp);
    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;  
    % DataModel to use
    nhpConfig.dataModelName = DataModel.WOLF_DATA_MODEL;
    nhpConfig.outcome = 'Correct';
    
    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of darwin source data files as cell array of cellstr
%  Uses column name 'matPath' from the excel file used for configuration
  allSessions=cellfun(@(x) dir(fullfile(srcFolder,x)),nhpTable.matPath,'UniformOutput',false);
  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);
  sessions = sessions(~cellfun(@isempty,sessions));   
end

function [ sessionName ] = getSessionName(sessionLocations)

end