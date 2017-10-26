
%% Read excel and find repeat penetrations : ap, ml and chamberLoc are same ...
    excelFile = 'config/SFN_NHP_Coordinates_All.xlsx';
    sheetName = 'Da_K';
    nhpTable = readtable(excelFile, 'Sheet', sheetName);




%% Visualize the function  over the range [-2,2] for x, y, and z.

[x,y,z] = meshgrid(-2:.2:2,-2:.25:2,-2:.16:2);
v = x.*exp(-x.^2-y.^2-z.^2);
xslice = [-1.2,.8,2]; 
yslice = 2; 
zslice = [-2,0];
slice(x,y,z,v,xslice,yslice,zslice)
colormap hsv


%% Draw cube..
% Center point is at coordinate [ax ay az].
ax = 20;  ay = 3;  az = 10;

% Full-width of each side of cube.
w = 15;

% For readability.
currAxis = w/2;

patch_args = { 'FaceColor', 'b', 'FaceAlpha', 0.3 };

% Side #1 of 6.
patch( 'XData', ax+[-currAxis -currAxis  currAxis  currAxis], 'YData', ay+[-currAxis  currAxis  currAxis -currAxis], 'ZData', az+[-currAxis -currAxis -currAxis -currAxis], patch_args{:} )
daspect( [1 1 1] )  % 1:1:1 aspect ratio.
hold on
% Side #2 of 6.
patch( 'XData', ax+[-currAxis -currAxis  currAxis  currAxis], 'YData', ay+[-currAxis  currAxis  currAxis -currAxis], 'ZData', az+[ currAxis  currAxis  currAxis  currAxis], patch_args{:} )
% Side #3 of 6.
patch( 'XData', ax+[-currAxis -currAxis  currAxis  currAxis], 'YData', ay+[ currAxis  currAxis  currAxis  currAxis], 'ZData', az+[-currAxis  currAxis  currAxis -currAxis], patch_args{:} )
% Side #4 of 6.
patch( 'XData', ax+[-currAxis -currAxis  currAxis  currAxis], 'YData', ay+[-currAxis -currAxis -currAxis -currAxis], 'ZData', az+[-currAxis  currAxis  currAxis -currAxis], patch_args{:} )
% Side #5 of 6.
patch( 'XData', ax+[ currAxis  currAxis  currAxis  currAxis], 'YData', ay+[-currAxis -currAxis  currAxis  currAxis], 'ZData', az+[-currAxis  currAxis  currAxis -currAxis], patch_args{:} )
% Side #6 of 6.
patch( 'XData', ax+[-currAxis -currAxis -currAxis -currAxis], 'YData', ay+[-currAxis -currAxis  currAxis  currAxis], 'ZData', az+[-currAxis  currAxis  currAxis -currAxis], patch_args{:} )

% Red dot in middle.
scatter3( ax, ay, az, 'or', 'filled', 'SizeData', 150 )

hold off

% Clears variables, command window, and closes all figures
clc; clear; close all

% Generates 300 linearly spaced points from 0 to 8*pi
x = linspace(0, 8*pi, 300);

% Creates the formula to be plotted
% (it's a multiplication between vector 'x' and vector 'cos(x)')
y = x .* cos(x);

% Plot it!
comet(x, y, .6)




%%draw clusters
clear all
s1=load('/mnt/teba/Users/Chenchal/clustering/processed/quality_1/jp060n01.mat');
diag1=diag(s1.contra_responseOnset_right.rsquared,1);
[y1,y2,d1]=clusterIt(diag1,0.5);

figure
faceColors= {'r','b','g','c','m','y'};
% vertices = [lowerLeft, lowerRight, upperRight, upperLeft]
% vertices = [x1y1, x2y1, x2y2, x1y2]
%x = x1,x2,x1,x2
x =1;
step = 0.1;

xData = [x-step x+step x+step x-step]; %centered at 1
currAxis=gca;
xlim([0 5]);
ylim([-10 36]);
for clust = 1:numel(y1)
    yData = [y1(clust) y1(clust) y2(clust)+1 y2(clust)+1];
    patch('XData', xData, 'YData', yData, 'FaceColor', faceColors{clust});
    hold on
end
%% draw probe
x = 1;
xVals = [x-step x+step];

% for y = 0:32
%     if y == 0
%         line([x xVals(1)],[0 1]);
%         line([x xVals(2)],[0 1]);
%     end
%     line(xVals,[y y])  
% end

% probe outline
xyData = [x-step, 36; x-step, -2; x, -5; x+step, -2; x+step, 36]
patch('XData',xyData(:,1),'YData',xyData(:,2),'FaceColor',[0.7 0.7 0.7], 'FaceAlpha', 0.5)
plot(zeros(32,1)+x,1:32,'ok')

set(currAxis,'Box','off','XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});

