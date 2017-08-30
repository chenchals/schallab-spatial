function plotBurst( spks, beginOfBurst, endOfBurst )
%PLOTBURST Summary of this function goes here
%   Detailed explanation goes here
    colors_='rbm';
    colors_=repmat(colors_,1,ceil(length(endOfBurst)/length(colors_)));
    yval = range(spks)*.25;
    %It takes less time to put '+' than draw line/ticks
    plot(spks,yval,'ko');
    hold on
    %set(findobj('type','axes'),'color',[1 1 1],'ytick',[],'box','on')
    for eobInd=1:length(endOfBurst)
        plot(spks(beginOfBurst(eobInd):endOfBurst(eobInd)),yval, strcat(colors_(eobInd), 'o'));
    end
end

