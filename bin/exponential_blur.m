function y = exponential_blur(x, neighbors)
    k = 1./(2.^(1:neighbors));
    k = [flip(k),1,k];
    y = conv(x,k,'same');
end