function [ axesHandles ] = plot8axes()
%PLOT28AXES Create handle for 2 rows by 4 columns plots
%  Uses plot8axesTemplate.m file.

    %% Parse exported guide template file
    % Template filename = [functionName]Template.m
    % Template file is in the same location as this file
    templateName = [mfilename('fullpath') 'Template.m'];
    cmd = ['grep -A 1 "Tag.*axes" ' templateName ' | grep "Position" | cut -d , -f 2'];
    [~,axesPositions] = system(cmd);
    axesPositions = cell2mat(textscan(axesPositions,'[%f %f %f %f]'));
    % scoot right all plots
    axesPositions(:,1) = axesPositions(:,1) + 0.02;
    %scoot down all plots
    axesPositions(:,2) = axesPositions(:,2) - 0.02;
 
    axesHandles = nan(size(axesPositions,1),1);
    figure('Units','normalized','Position',[0.02 0.02 0.97 0.97]);
    for ii = 1:size(axesPositions,1)
        axesHandles(ii) = axes('Position',axesPositions(ii,:),'Units','normalized');
        text(0.5,0.5,['axes' num2str(ii)])
    end
end

