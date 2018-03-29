function x = splitapply_crc(func, tab, grp)
    grp_id = unique(grp);
    x = cell2mat(arrayfun(@(g) func(tab(grp==g,:)), grp_id, 'UniformOutput', 0));
end
