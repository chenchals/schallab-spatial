function [ oSdfMat, units ] = my_multiUnitSdf( iSdfMat, unitIdOrder )
%MY_MULTIUNITSDF For each channel, sum sdfs of all units. Sort the resulting sdfs according to the sort order 
%   Inputs:
%   iSdfMat : A matrix of sdfs. Each row is an SDF
%             If 2D - Rows are cells. Number of cells = size(iSdfMat,1)
%             If 3D - Rows are trials. Number of cells = size(iSdfMat,3)
%
%   unitIdOrder: A table of 2 columns. Col1: UnitId; Col2: sortOrder
%               Example:
%                         spikeIds       unitSortOrder
%                      ______________    _____________
%                      'spikeUnit01a'     9           
%                      'spikeUnit01b'     9           
%                      'spikeUnit01c'     9           
%                      'spikeUnit02a'    10    
%
%                A cell array of unit Ids. The channel number in the
%                spike unit Id, will be used for merging and sorting
%  Note:  
%       nUnits = size(unitIdOrder,1) if table or
%       nUnits = numel(unitIdOrder) if cell array
%       MUST equal
%       size(iSdfMat,1) if 2D-matrix or size(iSdfMat,3) if 3D-matrix

  % Check iSdfMat
  switch ndims(iSdfMat)
      case 1
          error('Argument iSdfMat must be a 2D or a 3D matrix');
      case 2
          nUnits = size(iSdfMat,1);
      case 3
          nUnits = size(iSdfMat,3);
  end
  nTimes = size(iSdfMat,2);
  % Check unitIdOrder
  if istable(unitIdOrder) && ndims(unitIdOrder) == 2
      unitIds = table2cell(unitIdOrder(:,1));
      sortOrder = table2array(unitIdOrder(:,2));
  elseif iscell(unitIdOrder) && numel(unitIdOrder) == max(size(unitIdOrder))
      unitIds = unitIdOrder(:);
      sortOrder = str2num(cell2mat(cellfun(@(x) regexp(char(x),'\d\d','match'),unitIds)));
  else
      error('Argument unitIdOrder must be a cell array or a table');
  end
  if numel(unitIds) ~= nUnits
      error('Number of units in unitIdOrder [%2d] is not equal to 1st or 3rd dim of iSdfMat [%2d]',...
          numel(unitIds), nUnits);
  end
  
  % Compute the sum for each channel
  minmaxSort = minmax(sortOrder');
  oSdfMat = nan(range(minmaxSort)+1,nTimes);
  for seq = minmaxSort(1):minmaxSort(2)
      chanIndex = find(sortOrder == seq);
      units{seq,1} = unitIds(chanIndex);
      if ndims(iSdfMat) == 2
         oSdfMat(seq,:) = sum(iSdfMat(chanIndex,:),1);
      elseif ndims(iSdfMat) == 3
          unitSdfs = arrayfun(@(x) mean(iSdfMat(:,:,x),1),chanIndex,'UniformOutput',false);
          oSdfMat(seq,:) = sum(cell2mat(unitSdfs),1);
      end
  end

end

