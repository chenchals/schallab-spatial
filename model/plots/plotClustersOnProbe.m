%function [] = plotClustersOnProbe(baseProcessdedDir)
baseProcessdedDir = '/Users/elseyjg/temp/schalllab-spatial/processed/processed/quality_1';
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
        currAxis(c) = subplot(1,4,c);
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
        xlim = [0 probeLoc+1];
        ylim = [-8 50].*100;

set(currAxis, 'XLim', xlim, 'YLim', ylim)
set(currAxis,'Box','on','FontWeight', 'bold',...
     'XTick',[0:probeLoc+1],'XTickLabel',[{' '} sessionNames {' '}],'XTickLabelRotation', 45,...
     'YTick',[0:200:5000]); 
 
 arrayfun(@(x) set(get(currAxis(x),'Title'),'String', upper(conditions{x}),'Interpreter','none','FontSize', 12),...
     [1:4],'UniformOutput',false)

 figureTitle = baseProcessdedDir;
 h = axes('Units','normalized','Position',[.01 .95 .98 .01],'Visible','off');
 set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold','Interpreter','none');

%end

function [] = plotIt(sessionName, sessionInfo, probeLoc, beginEndCluster)

faceColors= {'r','b','g','c','m','y'};
channelSpacing = sessionInfo.channelSpacing;
if isnan(channelSpacing)
    channelSpacing = 200;
end
% vertices = [lowerLeft, lowerRight, upperRight, upperLeft]
% vertices = [x1y1, x2y1, x2y2, x1y2]
%x = x1,x2,x1,x2
xstep = 0.2;
% probe outline
maxChannels = numel(cell2mat(sessionInfo.ephysChannelMap));
xData = [probeLoc-xstep probeLoc-xstep probeLoc probeLoc+xstep probeLoc+xstep];
yData = [4900 -200 -800 -200 4900];
patch('XData',xData,'YData',yData,'FaceColor',[0.9 0.9 0.9],'LineWidth', 0.1)
hold on
plot(zeros(maxChannels,1)+probeLoc,(1:maxChannels).*channelSpacing,'ok') %

%plot clusters
xData = [probeLoc-xstep probeLoc+xstep probeLoc+xstep probeLoc-xstep]; %centered at 1
y1 = beginEndCluster(:,1).*channelSpacing;
y2 = (beginEndCluster(:,2)+1).*channelSpacing;

for clust = 1:numel(y1)
    yData = [y1(clust) y1(clust) y2(clust) y2(clust)];
    patch('XData', xData, 'YData', yData, 'FaceColor', faceColors{clust}, 'FaceAlpha', 0.5);
    hold on
end

end