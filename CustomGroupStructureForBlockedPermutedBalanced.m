function [ output_args ] = CustomGroupStructureForBlockedPermutedBalanced( metadata )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:numel(metadata)
        M = selectbyfield();
    C = cellfun(@(x) selectbyfield(x,'orientation','blocked permuted balanced'), ...
        {metadata.coords}, 'UniformOutput', 0);
    z = metadata(1).filters.filter;
    C = cellfun(@(x) x.ind(z,:), C, 'UniformOutput', false);
    tmp = coordGrouping(C,7,0,'cube')
end

