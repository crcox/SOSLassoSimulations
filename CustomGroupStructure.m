function [ G ] = CustomGroupStructure( metadata, condition )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    cix = cell(numel(metadata), 1);
    for i = 1:numel(metadata)
        M = selectbyfield(metadata,'subject', i);
        C = selectbyfield(M.coords,'orientation', condition);
        F = selectbyfield(M.filters,'label','not_padding');
        z = F.filter;
        ix = C.ind(z,:);
        x = ix(35);
        ix(36) = x;
        ix(ix>x) = ix(ix>x) + 6;
        x = ix(end-1);
        ix(end) = x;
        cix{i} = ix;
    end
    G = coordGrouping(cix,7,0,'cube');
end