function [ filelist ] = getFileList()
%GETFILELIST Summary of this function goes here
%   Detailed explanation goes here
   selDir = uigetdir;
   sStruct = dir([selDir filesep '*.mat']);
   filelist = strcat({sStruct.folder}', filesep, {sStruct.name}');
end

