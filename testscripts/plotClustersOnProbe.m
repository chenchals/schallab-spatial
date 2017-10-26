function [] = plotClustersOnProbe(baseProcessdedDir)
%plotClustersOnProbe('/mnt/teba/Users/Chenchal/clustering/processed/quality_1');

reverseYdir = true; % probe tip is pointing down :-)
d = dir(fullfile(baseProcessdedDir));

% get mat file list
fileNames = strcat({d.folder}',filesep,{d.name}');
probeLoc = 0;
conditions = {
    'contra_targetOnset'
    'contra_responseOnset'
    'ipsi_targetOnset'
    'ipsi_responseOnset'};
%new figure
figure
% for each file
for f = 1:numel(fileNames)
    fileName = fileNames{f};
    fprintf('doing file %s\n',fileName);
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
        currCond = conditions{c};
        currAxis(c) = subplot(1,4,c);
        ind = find(contains(fieldNames, currCond));
        if ~ind
            continue
        end
        rsquared = session.(char(fieldNames(ind))).rsquared;
        [boc,eoc] = clusterIt(diag(rsquared,1),0.5);
        plotProbe(probeLoc,info.channelSpacing,info.ephysChannelMap,[boc(:) eoc(:)],reverseYdir,'r');
        clear boc eoc
        drawnow
    end % end each condition
end %end each file

xlim = [0 probeLoc+1];
ylim = [-8 55].*100;
xtick = xlim(1):xlim(2);
ytick = 0:200:5000;

set(currAxis, 'XLim', xlim, 'YLim', ylim)
set(currAxis,'Box','on','FontWeight', 'bold',...
    'XTick',xtick,'XTickLabel',[{' '} sessionNames {' '}],'XTickLabelRotation', 45,...
    'YTick',ytick, 'TickLabelInterpreter', 'none');

arrayfun(@(x) set(get(currAxis(x),'Title'),'String', upper(conditions{x}),'Interpreter','none','FontSize', 12),...
    1:4,'UniformOutput',false)

figureTitle = baseProcessdedDir;
h = axes('Units','normalized','Position',[.01 .95 .98 .01],'Visible','off');
set(get(h,'Title'),'Visible','on');
title(figureTitle,'fontSize',20,'fontWeight','bold','Interpreter','none');

end

