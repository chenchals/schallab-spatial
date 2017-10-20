
threshold = 0.5;

s1 = load('processed/clustering/processed/helmholtz/2014-12-01a.mat');

condVars = s1.contra_responseOnset_left;

distMat = condVars.rsquared;

minImg = min(distMat(:));
maxImg = max(distMat(:));

tri = tril(distMat,-1);
tri(tri==0) = NaN;
tri(tri < threshold) = minImg;


figure;
currAxes = gca;

% Inorder for grod to show we need 2 overlapping axes
gridIm = ones(size(tri));
im = imagesc(rot90( tri,2));
colormap('Cool')
set(currAxes,'Box','off');
grid('on')
set(currAxes,'XMinorGrid','on','YMinorGrid','on');
alpha = ones(size(tri));
alpha(isnan(tri)) = 0;
im.AlphaData = rot90(alpha,2);
colormap('cool');
set(currAxes, 'YAxisLocation','right')
set(currAxes, 'XAxisLocation','top')


%line([1 31],[2 32])
%line([0 32],[1 33],'LineWidth',4);
line([0 32],[-1 31],'LineWidth',2, 'color','b','LineStyle','--');


%colorbar;
[boc,eoc,dtnc] = clusterIt(diag(distMat,-1),threshold);
% if only lower tri
% bocOffset = 0;
% eocOffset = 1;
% when lower triangle is ro90 ed
bocOffset = 2;
eocOffset = 3;
boc = boc + bocOffset;
eoc = eoc + eocOffset;
for cl = 1:numel(boc)
    line([boc(cl) eoc(cl)],[boc(cl) eoc(cl)], 'Color',[0 0 0], 'LineWidth',2);
end
xlabel('x-axes')
ylabel('y-axes')
%camroll(135);






