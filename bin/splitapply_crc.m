function x = splitapply_crc(func, tab, grp)
    grp_id = unique(grp);
    x = arrayfun(@(g) func(tab(grp==g,:)), grp_id, 'UniformOutput', false);
%     x = cellfun(@unpackSingleCell, X, 'UniformOutput', false);
    if iscell(x) && ~iscell(x{1})  && ~istable(x{1})
        e = cell2mat(x);
        if numel(e) == numel(grp_id)
            x = e;
        end
    end
    
end
% 
% function x = unpackSingleCell(x)
%     if iscell(x) && numel(x) == 1
%         x = x{1};
%     end
% end