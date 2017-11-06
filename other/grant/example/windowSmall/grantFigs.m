outDir = '/Users/elseyjg/temp/schalllab-spatial/';
%% Helmholtz
he={'/Users/elseyjg/temp/schalllab-spatial/processed/helmholtz/2014-12-17a.mat'
'/Users/elseyjg/temp/schalllab-spatial/processed/helmholtz/2014-12-01b.mat'};
%% Darwin_k
dak={'/Users/elseyjg/temp/schalllab-spatialprocessed/quality_4/Init_SetUp-160711-151215_probe1.mat'
     '/Users/elseyjg/temp/schalllab-spatial/processed/quality_4/Init_SetUp-160713-144841_probe1.mat'};
 
%% Broca
br={'/Users/elseyjg/temp/schalllab-spatial/processed/broca/bp235n01.mat'
     '/Users/elseyjg/temp/schalllab-spatial/processed/broca/bp238n01.mat'}; 
 
%% Joule
jo={'/Users/elseyjg/temp/schalllab-spatial/processed/joule/jp119n01.mat'
     '/Users/elseyjg/temp/schalllab-spatial/processed/joule/jp121n01.mat'};  
 
%% Gauss
ga={'/Users/elseyjg/temp/schalllab-spatial/processed/gauss/2015-02-18a.mat'
     '/Users/elseyjg/temp/schalllab-spatial/processed/gauss/2015-01-05.mat'};   
 
%% Darwin_WJ
da={'/Users/elseyjg/temp/schalllab-spatial/processed/darwin/2016-02-22a.mat'
     '/Users/elseyjg/temp/schalllab-spatial/processed/darwin/2016-02-26b.mat'};   
%% Plot all
cond = 'contra_targetOnset';
%heDak = [he; dak]; 

heDak = {'/Users/elseyjg/temp/schalllab-spatial/processed/helmholtz/2015-01-06a.mat'};
pos =[
    0.05 0.10 0.40 0.50
    0.49 0.10 0.40 0.50
    0.93 0.10 0.01 0.50
    0.04 0.70 0.90 0.25
    ];    

for s = 1:numel(heDak)
    axesHandles = createFig(pos);
    figH = get(axesHandles(1),'Parent');
    %% session    
    session = load(heDak{s});
    sessionFields = fieldnames(session);
    currCond = sessionFields{contains(sessionFields,cond)};
    channelMap = session.channelMap;
    %% Firing Rate
    timeWin = session.(currCond).sdfWindow;
    fr = session.(currCond).sdfMeanZtr;
    frMinMax = minmax(fr(:)');
    set(figH, 'currentaxes',axesHandles(1))
    plotFiringRateHeatmap(fr,channelMap,timeWin,frMinMax,'jet',{'contra_targetOnset', 'sdfMeanZtr Heatmap'},'r');
    box off;
    colorbar('off');
    %% distMat
    distMat = session.(currCond).rsquared;
    distMinMax = minmax(distMat(:)');
    set(figH, 'currentaxes',axesHandles(2))
    plotDistanceMatHeatmap(distMat,channelMap,distMinMax,'cool',{'contra_targetOnset', 'rsquared heatmap'},'r');
    
    %% Probe
    [boc, eoc] = clusterIt(diag(distMat,1),0.5);
    bocEoc = [boc(:), eoc(:)];
    set(figH, 'currentaxes',axesHandles(3))
    plotProbe(1,session.info.channelSpacing,channelMap,bocEoc,true);
    
    %% Infos
    infos = session.info;
    set(figH, 'currentaxes',axesHandles(4))
    set(gca,'box','on','XTick',[],'YTick',[]);
    addInfo(infos);
    h = title(session.session, 'FontWeight','bold', 'FontSize',15,'Interpreter','none');
    
    drawnow
    %% Save figs
    [~,fn,~] = fileparts(heDak{s});
    
    oFile = fullfile(outDir,[fn '_' cond]);
    fprintf('Saving figure to file %s\n',oFile);
    %saveas(figH,oFile,'jpg');
    %saveas(figH,oFile, 'fig');
    
end
%%
function [axesHandles] = createFig(axesPositions)
    figure('Units','normalized','Position',[0.05 0.05 0.80 0.80]);
    for ii = 1:size(axesPositions,1)
        axesHandles(ii) = axes('Position',axesPositions(ii,:),'Units','normalized');
    end
end

function addInfo(infoTable)
    currAxes = gca;
    currAxes.XTick = [];
    currAxes.YTick = [];
    currAxes.Visible = 'on';
    currAxes.Box = 'on';
    varNames=infoTable.Properties.VariableNames;
    % remove channelMap from varnames
    varNames = varNames(~contains(varNames,{'ephysChannelMap' 'rawPath' 'matPath'}));
    propsPerCol = 10;
    fontSize = 12;
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
end

%% Get next X position fron the previous plot extens
function [ xPos ] = getNextXPos(hText, columnGap)
        xPos = get(hText,'Extent');
        xPos = xPos(1) + xPos(3) + columnGap;
end

%% Figure1:
% Make da_k1 and da_k2 : targetOnset [-50  300]
% clustering : 
% 1. use absolute distance not channel number
%    use threshold of absolute distance to call a cluster
% 2. Bum channel: 
% 3. criteria: all channels are clusters to one cluster
% 4. plot of gaps vs criteria Versus plot of clusters size vs criteria
% 
%     templateName = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/other/grant/example/windowSmall/grantsFigTemplate.m';
%     cmd = ['grep -A 1 "Tag.*axes" ' templateName ' | grep "Position" | cut -d , -f 2'];
%     [a,z] = system(cmd)
%     