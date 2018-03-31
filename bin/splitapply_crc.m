function x = splitapply_crc(func, tab, grp)
    grp_id = unique(grp);
    X = arrayfun(@(g) func(tab(grp==g,:)), grp_id, 'UniformOutput', false);
    x = cellfun(@unpackSingleCell, X, 'UniformOutput', false);
%     x = cell2mat(X);
end

function x = unpackSingleCell(x)
    if iscell(x) && numel(x) == 1
        x = x{1};
    end
end