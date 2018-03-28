function [ output_args ] = UnivariateAnalysis( Annotated )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    m = fitlme(tbl,'activation~example_category+(1|subject)');

end

function y = gaussian_blur(x, neighbors)
    k = gausswin((neighbors*2)+1,2.3549);
    y = convolve(x,k,'same');
end

function y = exponential_blur(x, neighbors)
    k = 1./(2.^(1:neighbors));
    k = [flip(k),1,k];
    y = convolve(x,k,'same');
end

function y = boxcar_blur(x, neighbors)
    k = ones(1,(neighbors*2)+1);
    y = convolve(x,k,'same');
end 