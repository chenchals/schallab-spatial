function addSessionInfoAndTitle( figureTitle, session_info, session_analysisDate, varargin )
%ADDSESSIONINFOANDTITLE Summary of this function goes here
%   Detailed explanation goes here
    if numel(varargin)==0 || isempty(varargin{1})
        h = axes('Units','normalized','Position',[.01 .87 .98 .09]);
    else
        h = varargin{1};
    end
    scale = 0.7;
    titleFontsize = 12*scale;
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',titleFontsize,'fontWeight','bold','Interpreter','none');
    h.XTick = [];
    h.YTick = [];
    h.Visible = 'on';
    h.Box = 'on';
    infoTable = session_info;
    varNames=infoTable.Properties.VariableNames;
    % remove channelMap from varnames
    varNames = varNames(~contains(varNames,'ephysChannelMap'));
    propsPerCol = 5;
    fontSize = 10*scale;
    columnGap = 0.02;
    nCols = ceil(numel(varNames)/propsPerCol)+1;
    xPos=0.01;
    yPos = 0.9;
    for c = 1:nCols-1 % last col channelMap
        t = cell(propsPerCol,1);
        ind = (c-1)*propsPerCol+1:c*propsPerCol;
        ind = ind(ind<=numel(varNames));
        for i = 1:numel(ind)
            name = varNames{ind(i)};
            value = infoTable.(name);
            if isnumeric(value)
                value = num2str(value);
            else
                value = char(value);
            end
            t{i} = [name,' : ',value];
        end
        hText = text(xPos,yPos,t,'Interpreter','none',...
            'FontWeight','bold','FontSize',fontSize,...
            'VerticalAlignment', 'top','HorizontalAlignment','left');
        xPos = getNextXPos(hText, columnGap);
    end
    chanMap = infoTable.ephysChannelMap{:};
    chanRows = 4;
    chanCols = ceil(numel(chanMap)/chanRows);
    hText = text(xPos,yPos,{'ePhysChannelMap'; ...
        num2str(reshape(chanMap,chanCols,chanRows)','%02d, ')},...
        'Interpreter','none','FontWeight','bold','FontSize',fontSize,...
        'VerticalAlignment', 'top','HorizontalAlignment','left');
     xPos = getNextXPos(hText, columnGap);
            % write Analysis date
    text(xPos,yPos,['Analysis Date : ' session_analysisDate],...
        'Interpreter','none','FontWeight','bold','FontSize',fontSize,...
        'VerticalAlignment', 'top','HorizontalAlignment','left');
end

%% Get next X position fron the previous plot extens
function [ xPos ] = getNextXPos(hText, columnGap)
        xPos = get(hText,'Extent');
        xPos = xPos(1) + xPos(3) + columnGap;
end


