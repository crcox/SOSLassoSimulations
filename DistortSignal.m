function d = DistortSignal( d, UnitsToDistort, NoiseFunc )
%DISTORTSIGNAL Add noise to units of specified categories.
%   NoiseFunc is a function that accepts 1 argument, n, where n is the
%   number of units that need to have noise added to them.

    z = ismember(d.unit_category, UnitsToDistort);
    n = nnz(z);
    d.distorted_activation = d.activation;
    d.distorted_activation(z) = d.activation(z) + NoiseFunc(n);
end

