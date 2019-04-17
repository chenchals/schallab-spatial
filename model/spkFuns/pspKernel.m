function [ kernel ] = pspKernel()
%function [ kernel ] = pspKernel(growth, decay)
%PSPKERNEL Summary of this function goes here
%   Detailed explanation goes here
    growth = 1; decay = 100; %20;
    kernel = 0:decay;
    postHalfKernel = (1-(exp(-(kernel./growth)))).*(exp(-(kernel./decay)));
    %normalize area of the kernel
    postHalfKernel = postHalfKernel./sum(postHalfKernel);
    %set preHalfKernel to zero
    
    kernel=[zeros(1,numel(postHalfKernel)) postHalfKernel];
    % make kernel a column vector to do a convn on matrix
    kernel = kernel';
    %Note: convn works column wise for matrix:
    % resultTrialsInColumns  =  convn(TrialsInRowsMatrix' ,
    %    kernelColumnVector, 'same'); % not transpose in the end
    %
    % resultTrialsInRows  =  convn(TrialsInRowsMatrix' , kernelColumnVector,
    % 'same')'; % added transpose int he end
end

