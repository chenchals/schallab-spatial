
% Define Up, Down, Left, Right
isUp = @(x) x==90;
isDown = @(x) x==270;
isLeft = @(x) 90<x & x<270 ;
isRight = @(x) ~isLeft(x) & ~isUp(x) & ~isDown(x);



tWin = -100:200;
rWin = -200:100;

info = sess.info;

fn = fieldnames(sess);
fn = fn(contains(fn,'Onset'));
nStimLocs = sum(contains(fn,'target'));
for stims = 1:nSTimLocs
    
    
end



% target aligned
tFullWin = sess.targetOnset_0_360.sdfWindow;
tLogical = ismember(tFullWin,tWin);
t0 = sess.targetOnset_0_360.sdfMeanZtr(:,tLogical); 
t180 =sess.targetOnset_180.sdfMeanZtr(:,tLogical);
% response aligned
rFullWin = sess.responseOnset_0_360.sdfWindow;
rLogical = ismember(rFullWin,rWin);
r0 = sess.responseOnset_0_360.sdfMeanZtr(:,rLogical);
r180 = sess.responseOnset_180.sdfMeanZtr(:,rLogical);
% augment
t0r0 = [t0 r0];
tWinrWin = [tWin rWin];
% rsquared
t0Sq = corr(t0',t0').^2;
r0Sq = corr(r0',r0').^2;
t0r0Sq = corr(t0r0',t0r0').^2;

%
figure('Name',sess.session)

% plotFiringRateHeatmap( im, channelMap, timeWin, frMinMax, colorMap,  titleCell, titleColor )
% plotDistanceMatHeatmap( im, channelMap, distMinMax, colorMap,  titleCell, titleColor )
% targ align
subplot(3,2,1)
plotFiringRateHeatmap(t0,sess.info.ephysChannelMap,tWin,minmax(t0(:)'),'jet',{'targetOnset_0_360'},'k')
subplot(3,2,2)
plotDistanceMatHeatmap(t0Sq,sess.info.ephysChannelMap,minmax(t0Sq(:)'),'cool',{'rsquared'},'k')
% sac align
subplot(3,2,3)
plotFiringRateHeatmap(r0,sess.info.ephysChannelMap,rWin,minmax(r0(:)'),'jet',{'responseOnset_0_360'},'k')
subplot(3,2,4)
plotDistanceMatHeatmap(r0Sq,sess.info.ephysChannelMap,minmax(r0Sq(:)'),'cool',{'rsquared'},'k')
% augmented 
subplot(3,2,5)
plotFiringRateHeatmap(t0r0,sess.info.ephysChannelMap,tWinrWin,minmax(t0r0(:)'),'jet',{'target_response_Onset_0_360'},'k')
subplot(3,2,6)
plotDistanceMatHeatmap(t0r0Sq,sess.info.ephysChannelMap,minmax(t0r0Sq(:)'),'cool',{'rsquared'},'k')

