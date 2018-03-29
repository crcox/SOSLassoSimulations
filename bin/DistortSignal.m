function d = DistortSignal( d, strength)
%DISTORTSIGNAL Add noise to units of specified categories.
%   NoiseFunc is a function that accepts 1 argument, n, where n is the
%   number of units that need to have noise added to them.

    d.distorted_activation = d.activation + (d.noise .* strength);
end