function [ nhpSessions, nhpConfig ] = processDarwin()
%PROCESSJOULE Configure Joule sessions here
%     nhpConfig is a structured variable with fields that define how to
%     process matalb datafile for this NHP.
% see also PROCESSSESSIONS for how to define nhpConfig 

    nhpConfig.nhp = 'darwin';
    nhpConfig.nhpSourceDir = '/Users/chenchals/Projects/lab-schall/schalllab-clustering/data/darwin';
    nhpConfig.excelFile = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/config/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.sheetName = 'Da';
    nhpConfig.nhpOutputDir = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/processed/Darwin';
    % a function handle for getting sessions
    nhpConfig.getSessions = @getSessions;  
    
    nhpSessions = [];
    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
% Function to output the location of darwin source data files as cell array of cellstr
%  Uses column name 'rawFilename' from the excel file used for configuration
  rawFiles = nhpTable.rawFilename;
  toks = regexp(rawFiles,'.*-(\d*[ab]).*','tokens');
  sessionNames=cellfun(@(x) datestr(datenum(x{1},'mmddyya'),'yyyy-mm-dda') ,toks,'UniformOutput',false);  
  allSessions=cellfun(@(x) dir(fullfile(srcFolder, char(x),'DSP/DSP*/*_MG*.mat')),sessionNames,'UniformOutput',false);
  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);
  sessions = sessions(~cellfun(@isempty,sessions));

end
