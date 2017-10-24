%function [] = plotClustersOnProbe(baseProcessdedDir)
baseProcessdedDir = '/mnt/teba/Users/Chenchal/clustering/processed/quality_1';
d = dir(fullfile(baseProcessdedDir,'*.mat'));

% get mat file list
fileNames = strcat({d.folder}',filesep,{d.name}');
probeLoc = 0;
conditions = {
    'contra_targetOnset' 
    'contra_responseOnset'
    'ipsi_targetOnset'
    'ipsi_responseOnset'};
figH = figure;
% for each file 
for f = 1:numel(fileNames)
    fileName = fileNames{f};
    if isempty(who('-file',fileName,'info'))
        continue
    end
    session = load(fileName);
    probeLoc = probeLoc + 1; % 1st session
    fieldNames = fieldnames(session);
    sessionName = session.session;
    sessionNames{probeLoc} = sessionName;
    info = session.info;
    % for each condition do one figure
    for c = 1:numel(conditions)
        boc =[];
        eoc = [];
        currCond = conditions{c};
        currAxis(c) = subplot(2,2,c);
        ind = find(contains(fieldNames, currCond));
        if ~ind
            continue
        end
        rsquared = session.(char(fieldNames(ind))).rsquared;
        [boc,eoc] = clusterIt(diag(rsquared,1),0.5);
        plotIt(sessionName, info, probeLoc, [boc(:) eoc(:)]);
        drawnow
    end % end each condition
end %end each file
        xlim = [0 probeLoc+2];
        ylim = [-8 40].*100;

set(currAxis, 'XLim', xlim, 'YLim', ylim)
set(currAxis,'Box','off',...
     'XTick',[0:probeLoc+2],'XTickLabel',[{' '} sessionNames {' ' ' '}],...
     'YTick',[],'YTickLabel',{});
 set(currAxis,'XTickLabelRotation', 45);
 arrayfun(@(x) set(get(currAxis(x),'Title'),'String', conditions{x},'Interpreter','none'),[1:4],'UniformOutput',false)



%end

function [] = plotIt(sessionName, sessionInfo, probeLoc, beginEndCluster)

currAxis=gca;
faceColors= {'r','b','g','c','m','y'};
% vertices = [lowerLeft, lowerRight, upperRight, upperLeft]
% vertices = [x1y1, x2y1, x2y2, x1y2]
%x = x1,x2,x1,x2
xstep = 0.1;
xData = [probeLoc-xstep probeLoc+xstep probeLoc+xstep probeLoc-xstep]; %centered at 1
channelSpacing = sessionInfo.channelSpacing;
y1 = beginEndCluster(:,1).*channelSpacing;
y2 = (beginEndCluster(:,2)+1).*channelSpacing;

for clust = 1:numel(y1)
    yData = [y1(clust) y1(clust) y2(clust) y2(clust)];
    patch('XData', xData, 'YData', yData, 'FaceColor', faceColors{clust});
    hold on
end
% probe outline
maxChannels = numel(cell2mat(sessionInfo.ephysChannelMap));
xData = [probeLoc-xstep probeLoc-xstep probeLoc probeLoc+xstep probeLoc+xstep];
yData = [36 -2 -5 -2 36].*channelSpacing;

patch('XData',xData,'YData',yData,'FaceColor',[0.9 0.9 0.9], 'FaceAlpha', 0.8)
plot(zeros(maxChannels,1)+probeLoc,(1:maxChannels).*channelSpacing,'ok') %

end