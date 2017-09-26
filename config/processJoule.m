function [ nhpSessions ] = processJoule()
%PROCESSJOULE Configure Joule sessions here

    nhpConfig.nhp = 'joule';
    nhpConfig.srcNhpDataFolder = '/Volumes/schalllab/data/Joule';
    nhpConfig.excelFile = '/Users/elseyjg/temp/schalllab-spatial/config/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.nhpSheetName = 'Jo';
    nhpConfig.outputFolder = '/Users/elseyjg/temp/schalllab-spatial/processed';
    nhpConfig.getSessions = @getSessions;  
    nhpSessions = processSessions(nhpConfig);
    
end

function [ sessions ] = getSessions(srcFolder, nhpTable)
  sessions = strcat(srcFolder, filesep, regexprep(nhpTable.filename,'''',''));
end
