function y = boxcar_blur(x, neighbors)
    k = ones(1,(neighbors*2)+1);
    y = convolve(x,k,'same');
end 