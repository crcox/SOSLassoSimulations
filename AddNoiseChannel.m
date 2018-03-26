function d = AddNoiseChannel( d, UnitsToDistort, NoiseFunc)
%ADDNOISECHANNEL Add noise to units of specified categories.
%   NoiseFunc is a function that accepts 1 argument, n, where n is the
%   number of units that need to have noise added to them.

    z = ismember(d.unit_category, UnitsToDistort);
    n = nnz(z);
    d.noise = zeros(numel(z),1);
    if isfunction(NoiseFunc)
        d.noise(z) = NoiseFunc(n);
    else
        d.noise(z) = NoiseFunc;
    end
end

function b = isfunction(x)
    b = isa(x, 'function_handle');
end