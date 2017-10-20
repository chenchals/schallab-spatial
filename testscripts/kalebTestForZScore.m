s1=load('/mnt/teba/Users/Chenchal/Jacob/clustering/processed/darwink/Init_SetUp-160711-151215_probe1.mat');

respAlign{1} = s1.contra_targetOnset_right.sdfMean;
respAlign{2} = s1.contra_responseOnset_right.sdfMean;
respAlign{3} = s1.ipsi_targetOnset_left.sdfMean;
respAlign{4} = s1.ipsi_responseOnset_left.sdfMean;

respTimes{1} = s1.contra_targetOnset_right.sdfWindow;
respTimes{2} = s1.contra_responseOnset_right.sdfWindow;
respTimes{3} = s1.ipsi_targetOnset_left.sdfWindow;
respTimes{4} = s1.ipsi_responseOnset_left.sdfWindow;
% bl [-100:0] assumes that the respAlign{1} is always targetAligned
normResp = klNormRespv2(respAlign,respTimes,'ztrbl','-r',respTimes,'bl',[-100:0]);

figure(); 
subplot(1,2,1); 
plot(respTimes{1},respAlign{1});
title('Raw');
subplot(1,2,2);
plot(respTimes{1},normResp{1});
title('ZTR');