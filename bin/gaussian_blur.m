function y = gaussian_blur(x, neighbors)
    k = gausswin((neighbors*2)+1,2.3549);
    y = convolve(x,k,'same');
end