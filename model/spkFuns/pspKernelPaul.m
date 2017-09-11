function [ kernel ] = pspKernelPaul()
%function [ kernelShape ] = pspKernelPaul( growth, decay )
%PSPKERNELPAUL Summary of this function goes here
%   Detailed explanation goes here
    growth = 1; decay = 20;
    kernelHalfLength = round(decay * 8);
    kernelHalfTimes = 0 : kernelHalfLength;
    kernelHalf1 = zeros(1, kernelHalfLength);
    kernelHalf2 = (1 - (exp(-(kernelHalfTimes ./ growth)))) .* (exp(-(kernelHalfTimes ./ decay)));
    kernelHalf2 = kernelHalf2 ./ sum(kernelHalf2);
    kernel = [kernelHalf1, kernelHalf2];
end

