function [ kernel ] = pspKernel()
%function [ kernel ] = pspKernel(growth, decay)
%PSPKERNEL Summary of this function goes here
%   Detailed explanation goes here
    growth = 1; decay = 20;
    halfBinWidth = round(decay*8);
    binSize = (halfBinWidth*2)+1;
    kernel = 0:halfBinWidth;
    postHalfKernel = (1-(exp(-(kernel./growth)))).*(exp(-(kernel./decay)));
    %normalize area of the kernel
    postHalfKernel = postHalfKernel./sum(postHalfKernel);
    %set preHalfKernel to zero
    kernel(1:halfBinWidth) = 0;
    kernel(halfBinWidth+1:binSize) = postHalfKernel;
    %kernel = kernel.*1000;
    % make kernel a column vector to do a convn on matrix
    kernel = kernel';
    %Note: convn works column wise for matrix:
    % resultTrialsInColumns  =  convn(TrialsInRowsMatrix' ,
    %    kernelColumnVector, 'same'); % not transpose in the end
    %
    % resultTrialsInRows  =  convn(TrialsInRowsMatrix' , kernelColumnVector,
    % 'same')'; % added transpose int he end
end

