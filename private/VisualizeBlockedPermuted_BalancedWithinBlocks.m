[ix,tmp] = generateBlockedPermuted(struct('SH',7,'AH',7,'noise',28,'subjects',10),'balance','within');
clear X;
for i = 1:10
    X(:,i) = tmp.unit_category(ix(:,i),:);
end
X = array2table(X);
X.block = ordinal( ...
     [repmat(4,7,1);repmat(1,9,1);repmat(4,7,1);repmat(2,6,1);repmat(4,7,1);repmat(3,6,1)], ...
     {'Block 1','Block 2','Block 3','Gap'}, ...
     1:4);
X.block_id = [1:7,1:9,1:7,1:6,1:7,1:6]';
disp(X);
writetable(X,'BlockedPermuted_BalancedWithinBlocks.csv');