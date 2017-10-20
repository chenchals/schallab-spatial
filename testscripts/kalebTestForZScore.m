s1=load('/Volumes/schalllab/Users/Chenchal/clustering/processed/quality_1/jp060n01.mat');

respAlign{1} = s1.ipsi_targetOnset_left.sdfMean;
respAlign{2} = s1.ipsi_responseOnset_left.sdfMean;
respAlign{3} = s1.contra_targetOnset_right.sdfMean;
respAlign{4} = s1.contra_responseOnset_right.sdfMean;

respTimes{1} = s1.ipsi_targetOnset_left.sdfWindow;
respTimes{2} = s1.ipsi_responseOnset_left.sdfWindow;
respTimes{3} = s1.contra_targetOnset_right.sdfWindow;
respTimes{4} = s1.contra_responseOnset_right.sdfWindow;
% bl [-100:0] assumes that the respAlign{1} is always targetAligned
normRespBl = klNormRespv2(respAlign,respTimes,'ztrbl','-r',respTimes,'bl',[-100:0]);
normResp = klNormRespv2(respAlign,respTimes,'ztr','-r',respTimes);

% figure(); 
% subplot(1,2,1); 
% plot(respTimes{1},respAlign{1});
% title('Raw');
% subplot(1,2,2);
% plot(respTimes{1},normResp{1});
% title('ZTR');

corrFx = @(x) (1-pdist2(x,x,'correlation')).^2;

corrMeans = cellfun(corrFx,respAlign,'UniformOutput',false);
corrMeansZtr =  cellfun(corrFx,normResp,'UniformOutput',false);
corrMeansZtrBl =  cellfun(corrFx,normRespBl,'UniformOutput',false);
for ii =1:numel(normResp)
  plotIt(corrMeans{ii},corrMeansZtr{ii},corrMeansZtrBl{ii},respAlign{ii},normResp{ii},normRespBl{ii});
end

function [] = plotIt(x,y,z,fx,fy,fz)
  figure
  subplot(3,3,1)
  imagesc(x)
  title('Mean')
  subplot(3,3,2)
  imagesc(y)
  title('MeanZtr')
  subplot(3,3,3)
  imagesc(z)
  title('MeanZtrBl')
  % Fr Plots
  subplot(3,3,4)
  plot(1:501,fx)
  title('MeanFr')
  subplot(3,3,5)
  plot(1:501,fy)  
  title('MeanZtrFr')
  subplot(3,3,6)
  plot(1:501,fz)
  title('MeanZtrBlFr')

  % Fr imagesc
  subplot(3,3,7)
  imagesc(fx)
  title('Mean')
  subplot(3,3,8)
  imagesc(fy)
  title('MeanZtr')
  subplot(3,3,9)
  imagesc(fz)
  title('MeanZtrBl')
  
  
end






% 
% condsOrd = {
% 'contra_targetOnset'
% 'contra_responseOnset'
% 'ipsi_targetOnset'
% 'ipsi_responseOnset'};
% 
% conds = fieldnames(s1);
% conds = conds(~cellfun(@isempty,regexp(conds,'targetOnset|responseOnset','match')))
% 
% respAlign2 = cellfun(@(x) s1.(char(x)).sdfMean,conds,'UniformOutput',false);
% respTimes2 = cellfun(@(x) s1.(char(x)).sdfWindow,conds,'UniformOutput',false);
% 
% normRespZtr =  klNormRespv2(respAlign2,respTimes2,'ztr','-r',respTimes);
% 
