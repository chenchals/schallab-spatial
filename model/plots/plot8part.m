function [ axesHandles, infosHandle ] = plot8part()
%PLOT28AXES Create handle for 2 rows by 4 columns plots
%  Uses plot8axesTemplate.m file.

    %% Parse exported guide template file
    % Template filename = [functionName]Template.m
    % Template file is in the same location as this file
    templateName = [mfilename('fullpath') 'Template.m'];
    cmd = ['grep -A 1 "Tag.*axes" ' templateName ' | grep "Position" | cut -d , -f 2'];
    [~,axesPositions] = system(cmd);
    axesPositions = cell2mat(textscan(axesPositions,'[%f %f %f %f]'));
    
    cmd = ['grep -A 1 "Tag.*infos" ' templateName ' | grep "Position" | cut -d , -f 2'];
    [~,axesInfosPosition] = system(cmd);
    axesInfosPosition = cell2mat(textscan(axesInfosPosition,'[%f %f %f %f]'));
 
    axesHandles = nan(size(axesPositions,1),1);
    figH = figure('Units','inches','Position',[17.6 14.0 15.0 9.5]);
    for ii = 1:size(axesPositions,1)
        axesHandles(ii) = axes('parent', figH, 'Position',axesPositions(ii,:));
        title(['axes' num2str(ii)])
    end
    infosHandle = axes('Parent',figH,'Position',axesInfosPosition);
end

