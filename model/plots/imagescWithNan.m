function [] = imagescWithNan(inMat, cLimits, threshold, nanColorGray, colorbarName)
%IMAGESCWITHNAN Summary of this function goes here
%% Image scale with balnk/gray for Nans
    axesH = gca;
    alpha = ones(size(inMat));
    alpha(isnan(inMat)) = 0;
    if ~isempty(threshold)
        inMat(inMat<threshold) = 0;
        cLimits = [0 1];
    end    
    im = imagesc(inMat,cLimits);
    colormap(axesH, colorbarName);
    im.AlphaData = alpha;
    grayness = 1;
    if ~isempty(nanColorGray)
        grayness = nanColorGray;
    end
    set(axesH,'Color',grayness*[1 1 1]);
    h = colorbar;
    set(h,'YLim',cLimits);
end

