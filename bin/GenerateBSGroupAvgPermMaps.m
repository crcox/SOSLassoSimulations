function P = GenerateBSGroupAvgPermMaps(permutation_maps, mask, bs_selections)
% Permutation maps should be formated as a cell array with nsubj cells,
% each cell containing a matrix of permutation maps with a row for each
% non-zero voxel and a column for each permutation solution. The mask used
% to select the values in each column of this matrix is provided as the
% second parameter. bs_selections will have a row for each desired
% group map, and a column for each subject. Each row describes which of the
% how to sample the subject-specific permutation maps to average into a
% group map.
    nperm = size(bs_selections, 2);
    nsubj = numel(permutation_maps);
    if isvector(mask)
        bs_perm_set = zeros(numel(mask), nsubj);
        is3DMask = false;
    else
        bs_perm_set = zeros([size(mask), nsubj]);
        is3DMask = true;
    end
    
    P = zeros(nnz(mask), nperm);
    nchar = 0;
    for i = 1:nperm
        fprintf(repmat('\b',1,nchar));
        nchar = fprintf('%d',i);
        ix = bs_selections(:,i);
        if is3DMask
            for j = 1:nsubj
                bs_perm_set(:,:,:,j) = permutation_maps{j}(:,:,:,ix(j));
            end
            bs_perm_mean = mean(bs_perm_set, 4);
            P(:,i) = bs_perm_mean(mask);
        else
            for j = 1:nsubj
                bs_perm_set(:,j) = permutation_maps{j}(:,ix(j));
            end
            bs_perm_mean = mean(bs_perm_set, 2);
            P(:,i) = bs_perm_mean;
        end
    end
    fprintf('Done.\n');
end
