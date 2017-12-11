function [  ] = processSpatialAnalysisFig( varargin )
%PROCESSSPATIALANALLYSISFIGS Draw figures for Spatial Analysis
%  Use output file from processSpatialAnalysis
% see also PROCESSSPATIALANALYSIS
   % fileLoc = '/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed/darwin/MEM/moranSdfMean/2016-02-22a_MEM_Q2.mat';
  %fileLoc ='/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed/darwin/MEM/moranSdfMeanZtr/2016-02-26a_MEM_Q2.mat';
    %fileLoc ='moranSdfMeanZtr/2016-02-26a';
    fileLoc = varargin{1};
    fprintf('Processing file %s\n', fileLoc);
    sess = load(fileLoc);
    [fp, fn, ~] = fileparts(fileLoc);
    oDir = [fp filesep 'fig'];
    oFile = fullfile(oDir,fn);
    
    % available conditions
    % do ipsi contra for now
    
    conds = fieldnames(sess);
    curr = 'contra';
    curr_conds = conds(~cellfun(@isempty, regexp(conds,curr))); 
    
    %gather plot data
    
    figName = [fn ' - ' upper(curr)];
    [figH, axH, plotPos] = drawStripes(3,8,figName);
    allAx = [];
    for ii = numel(curr_conds):-1:1
        curr_cond = curr_conds{ii};
        %plot r, 1 FR
        [axH,allAx(end+1,1)] = nextPlot(figH,axH);
         sdfWin = sess.(curr_cond)(1).sdfMean.sdfWindow;
         y = sess.(curr_cond)(1).sdfMean.sdfMatrix;
        showMat(y,sdfWin,'jet');
        addTitle({curr_cond;'FR Heatmap'},ii)
        %plot r, 2 r^2
        [axH,allAx(end+1,1)] = nextPlot(figH,axH);
        imagesc(sess.(curr_cond)(1).sdfMean.rsquared);
        colormap(gca,'cool');
        %alpha(0.8)
        addTitle('r-squared',ii)
        for dd = 1:3
            %plot r, 3,5,7 moran local
            [axH,allAx(end+1,1)] = nextPlot(figH,axH);
            m = sess.(curr_cond)(dd).sdfMean.local_I;
            D = sess.(curr_cond)(dd).sdfMean.neighborD;
            if iscell(sdfWin)
                %split moran
                y{1} = m(:,1:size(sdfWin{1},2));
                y{2} = m(:,size(sdfWin{1},2)+1:end);               
            else
                y = m;
            end
            showMat(y,sdfWin,'cool');
            addTitle(['moran-l-' num2str(D)],ii)
            %plot r, 4,6,8 moran pval
            [axH,allAx(end+1,1)] = nextPlot(figH,axH);
            m = sess.(curr_cond)(dd).sdfMean.local_pval;
            if iscell(sdfWin)
                %split moran
                y{1} = m(:,1:size(sdfWin{1},2));
                y{2} = m(:,size(sdfWin{1},2)+1:end);               
            else
                y = m;
            end
            showMat2(y,sdfWin,true,'gray');
            %caxis([0 0.1])
            drawnow
            addTitle(['moran-l pval-' num2str(D)],ii)
        end
    end
    infoPos2 = plotPos(end,2)+plotPos(end,3)*2+0.05;

    infoPos = [plotPos(1,1) infoPos2 0.97-plotPos(1,1) 0.97-infoPos2];
    titleAxes = axes('Position',infoPos ,'Units','normalized');
    addSessionInfoAndTitle(figName,sess.sessionInfo, sess.processedDate, titleAxes);
    
    fprintf('Saving moran analysis figure to location %s\n',oFile);
    if ~exist(oDir,'dir')
        mkdir(oDir);
    end
    saveas(figH,oFile,'jpg');
    saveas(figH,oFile, 'fig');
    %delete(figH);
    %close all
    
end
function showMat(inMat,sdfWin,colMap)
  showMat2(inMat,sdfWin,false,colMap);
end

function showMat2(inMat,sdfWin, isPval,colMap)
    if ~iscell(inMat)
        if isPval
          imagesc(inMat,[0 0.1]);
          colormap(gca,'gray')
        else
          imagesc(inMat);
          colormap(gca,colMap)
        end
      
      %alpha(0.8);
      %colorbar;
      updateXTicks(sdfWin)
      if isPval
          %caxis([0 0.1])
      end
    else
        % we have 2 plots to darw
        pos = get(gca,'Position');
        currH = gca;
        set(currH,'XTick',[],'YTick',[],'Visible','off')
        gap = 0.002;
        pw = (pos(3)-gap)/2;
        posN(1,:) = [pos(1) pos(2) pw pos(4)];
        posN(2,:) = [pos(1)+pw+gap pos(2) pw pos(4)];
        for ii = 1:2
            if ii == 1
                sdfWinN = sdfWin{ii}(1:end-5);
            else
                sdfWinN = sdfWin{ii};
            end
            axes('Position',posN(ii,:),'Units','normalized');
            showMat2(inMat{ii},sdfWinN,isPval,colMap);
        end
        set(gcf,'CurrentAxes',currH);
    end
end

function updateXTicks(sdfWin)
    rot = 45;
    xtick = 1:50:numel(sdfWin);
    xticklabel = arrayfun(@(x) num2str(x),min(sdfWin):50:numel(sdfWin),'UniformOutput',false);
    set(gca,'XTick', xtick,'XTickLabel', xticklabel,'FontSize',8,'TickDir', 'both','XTickLabelRotation', rot)
    line([find(sdfWin==0) find(sdfWin==0)],get(gca,'YLim'),'Color','r','LineWidth',1);
    xlabel('time(ms)','VerticalAlignment','baseline')
end

function [] = addTitle(titleTxt,rowIdx)
    if rowIdx == 1
        if numel(titleTxt)==2
            title({titleTxt{1} ' '},'Interpreter','none','FontSize',10, 'Color','r') ;
            text(range(get(gca,'XLim'))/2,-1,titleTxt{2},'FontSize',10,'FontWeight','bold','HorizontalAlignment','center')
        else
            title(titleTxt,'Interpreter','none','FontSize',10) ;
        end
    elseif numel(titleTxt)==2
        title(titleTxt{1},'Interpreter','none','FontSize', 10, 'Color', 'r')
    end    
end

function [axH, ax]= nextPlot(figH,axH)
   ax = axH(1);
   axH = axH(2:end);
   set(figH,'CurrentAxes',ax);
end

function [ figH, ax,pp ] = drawStripes(nRows,nCols,name)
    figH=figure('Name',name,...
        'Units','normalized',...
        'Position',[0.05 0.05 0.8 0.9]);
    ht = (1-0.1)/(nRows+1);
    wd = (1-0.1)/nCols;
    xgut = 0.004;
    ygut = 0.02*nRows;
    pos = [0.05 0.05 wd ht];
    plotNo = 0;
    for ii = 1:nRows
        for jj = 1:nCols
            plotNo = plotNo+1;
            pos1 = 0.04+(wd+xgut)*(jj-1);
            pos2 = 0.04+(ht+ygut)*(ii-1);
            pp(plotNo,:) = [pos1 pos2 wd ht];
            ax(plotNo) = axes('Position',pp(plotNo,:) ,'Units','normalized');
            %text(0.5,0.5,['axes' num2str(plotNo)])
        end
    end
  
end