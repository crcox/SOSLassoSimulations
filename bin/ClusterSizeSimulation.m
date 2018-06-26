function [k, ClusterSizeStats] = ClusterSizeSimulation(perm_maps, mask, pth_voxel_level, pth_fwer, RealShouldBeHigher)
%% Cluster size simulation
% 1. All 10,000 bootstrapped group-mean permutation maps are computed
% and stored in P, each as a vector of cortical voxels (~13% of voxels in
% volume).
%
% 2. Then, each of the 10,000 maps are ranked relative to the rest of the
% set.
%
% 3. The ranks are then filtered to implement a p-threshold. *Assessing
% different p-thresholds requires independent simulations, so after
% generating P, the procedure can be parallelized across different
% machines. In fact, each loop is independent, so the procedure lends
% itself to parallelization.*
%
% 4. The non-zero values (after filtering) is then projected into 3D, and
% clusters are quantified.
%
% 5. The number of clusters of each size are recorded, aggregating over the
% permutation maps.
%
% 6. These counts are normalized by the total number of observed clusters
% to obtain a probability of each cluster size.
%
% 7. We can then determine the cluster threshold (k or greater) that is
% associated with p < 0.05. This k, combined with the p-threshold used in
% (3), achieves FWE corrected statistical control at the cluster level in
% the sample.
%
% The whole process, for a single p-threshold, will take 30--60 minutes for
% 10,000 permutations and conventional functional resolution (3x3x3 mm
% voxels) when considering all voxels in cortex (30--40k).
% P-threshold

% rank-threshold
if nargin < 4
    pth_fwer = 0.05;
end
nperm = size(perm_maps, 2);
rth = ceil(nperm * (1-pth_voxel_level));
ClusterSizeCount = zeros(size(perm_maps,1),1);
nperm = size(perm_maps,2);
nchar = 0;

for i = 1:nperm
    fprintf(repmat('\b',1,nchar));
    nchar = fprintf('%d',i);
    B = zeros(size(mask), 'logical');
% for profiling purposes (set nperm to something smaller).
%     x = ExpansionAndGT(perm_maps, i);
%     y = SumByRow(x); %sum(x,2);
%     b = GT(y,rth); % b = y >= rth;
    if RealShouldBeHigher
        b = sum(bsxfun(@gt, perm_maps(:,i), perm_maps), 2) >= rth;
    else
        b = sum(bsxfun(@lt, perm_maps(:,i), perm_maps), 2) >= rth;
    end
    B(mask) = b;
    Clusters = bwconncomp(B);
    nn = cellfun('prodofsize', Clusters.PixelIdxList);
    tt = tabulate(nn);
    n = size(tt,1);
    ClusterSizeCount(1:n) = ClusterSizeCount(1:n) + tt(:,2);
end
[k, ClusterSizeStats] = ClusterSizeForFWER(ClusterSizeCount, pth_fwer);
fprintf('Done.\n');
end
% for profiling purposes
% function x = ExpansionAndGT(perm_maps, i) % about 20 s per 100 calls
%     x = bsxfun(@gt, perm_maps(i,:), perm_maps);
% end
% function y = SumByRow(x) % about 10 s per 100 calls
%     y = sum(x, 1);
% end
% function b = GT(y, rth) % about 0.007 s per 100 calls
%     b = y >= rth;
% end
