function [ nhpSessions ] = processJoule()
%PROCESSJOULE Summary of this function goes here
%   Detailed explanation goes here

% $Id$

    nhpConfig.nhp = 'joule';
    nhpConfig.srcNhpDataFolder = '/Volumes/schalllab/data/Joule';
    nhpConfig.excelFile = '/Users/subravcr/Projects/lab-schall/schalllab-spatial/config/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.nhpSheetName = 'Jo';
    nhpConfig.outputFolder = '/Users/subravcr/Projects/lab-schall/schalllab-spatial/processed';
    nhpSessions = processSessions(nhpConfig);
    
end

