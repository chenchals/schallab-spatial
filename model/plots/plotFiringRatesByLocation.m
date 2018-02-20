function plotFiringRatesByLocation( frStruct )
%PLOTFIRINGRATESBYLOCATION 
% Use output of PROCESSSESSIONSBYLOCATION
% see also PROCESSSESSIONSBYLOCATION output

  fn = fieldnames(frStruct);
  tOnsets = fn(~cellfun(@isempty, regexp(fn,'targetOnset_\d*$')));
  rOnsets = fn(~cellfun(@isempty, regexp(fn,'responseOnset_\d*$')));
  tFrs = cellfun(@(x) frStruct.(x).sdfMeanZtr,tOnsets,'UniformOutput',false);
  rFrs = cellfun(@(x) frStruct.(x).sdfMeanZtr,rOnsets,'UniformOutput',false);
  trFrs=[cell2mat(tFrs) cell2mat(rFrs)];
  %minFr = round(prctile(trFrs(:),0.5)*10)/10;
  %maxFr = round(prctile(trFrs(:),99.5)*10)/10;
  minFr = round(min(trFrs(:)')*10)/10;
  maxFr = round(max(trFrs(:)')*10)/10;
  figure
  for ii = 1:numel(tOnsets)
      tCond = tOnsets{ii};
      rCond = rOnsets{ii};
      loc = str2double(char(regexp(tCond,'\d*$','match')));
      subplot(3,3,getSubplotIndex(loc));
      imagesc(frStruct.(tOnsets{ii}).sdfMeanZtr,[minFr maxFr])
      colorbar
      title(tCond, 'Interpreter','none')
      drawnow
  end  
end

function [plotLoc] = getSubplotIndex(loc)
    % always use 3 by 3 plot, 
    locs = [0 45 90 135 180 225 270 315];
    plotLocs = [6 3 2 1 4 7 8 9]; 
    if loc ==360
        loc = 0;
    end
    plotLoc = plotLocs(locs==loc);      
end

