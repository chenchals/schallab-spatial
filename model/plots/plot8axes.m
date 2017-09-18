function [ axesHandles ] = plot8axes()
%PLOT28AXES Summary of this function goes here
%   Detailed explanation goes here
    %% Parse exported guide template file
    % Template filename = [functionName]Template.m
    % Template file is in the same location as this file
    templateName = [mfilename('fullpath') 'Template.m'];
    cmd = ['grep -A 1 "Tag.*axes" ' templateName ' | grep "Position" | cut -d , -f 2'];
    [~,axesPositions] = system(cmd);
    axesPositions = cell2mat(textscan(axesPositions,'[%f %f %f %f]'));
    axesHandles = nan(size(axesPositions,1),1);
    figure('Units','normalized','Position',[0.05 0.05 0.85 0.85]);
    for ii = 1:size(axesPositions,1)
        axesHandles(ii) = axes('Position',axesPositions(ii,:),'Units','normalized');
        text(0.5,0.5,['axes' num2str(ii)])
    end

end

