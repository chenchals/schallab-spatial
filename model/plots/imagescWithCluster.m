function [] = imagescWithCluster(inMat, cLimits, threshold, nanColorGray, colorbarName)
%IMAGESCWITHCLUSTER Summary of this function goes here
%   Detailed explanation goes here
    axesH = gca;
    maxChannels = size(inMat,1);
    minImg = min(inMat(:));
    % get data for lower triangle
    if ~isempty(threshold)
        %lowerTri = tril(inMat,-1);
        lowerTri = triu(inMat,1);
        lowerTri(lowerTri==0) = NaN;
        lowerTri(lowerTri < threshold) = minImg;
        cLimits = [0 1];
    end
    im = imagesc(lowerTri, cLimits);
    colormap(axesH,colorbarName);
    % transparency / alpha
    alpha = ones(size(lowerTri));
    alpha(isnan(lowerTri)) = 0;
    im.AlphaData = alpha;
    grayness = 1;
    if ~isempty(nanColorGray)
        grayness = nanColorGray;
    end
    set(axesH,'Color',grayness*[1 1 1]);
    colormap('cool');
    set(axesH,'Box','off');
    grid('on')
    set(axesH,'XMinorGrid','on','YMinorGrid','on');
    set(axesH, 'XAxisLocation','top','YAxisLocation','right');
    % set(axesH, 'View', [45 90])

    %draw diag line for diag -1
    %line([0 maxChannels],[1 maxChannels+1],'LineWidth',4);
    line([1 maxChannels+1],[0 maxChannels],'LineWidth',4);
    % get cluster extents
    [boc,eoc,~] = clusterIt(diag(inMat,-1),threshold);
    bocOffset = 0;
    eocOffset = 1;
    boc = boc + bocOffset;
    eoc = eoc + eocOffset;
    
    faceColors= {'r','b','g','c','m','y'};
    
    for cl = 1:numel(boc)
        line([boc(cl) eoc(cl)],[boc(cl) eoc(cl)], 'Color',faceColors{cl}, 'LineWidth',4);
    end

    % colorbar
    h = colorbar;
    set(h,'YLim',cLimits);

end

