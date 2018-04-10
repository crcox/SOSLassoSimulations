[ix,tmp] = generateSplitPermuted(struct('SH',7,'AH',7,'noise',28,'subjects',10));
clear X;
for i = 1:10
    X(:,i) = tmp.unit_category(ix(:,i),:);
end
X = array2table(X);
X.block = ordinal( ...
    [ones(7,1); repmat(2,7,1);repmat(3,7,1);repmat(4,21,1)], ...
    {'Block 1','Block 2','Block 3','Block 4'}, ...
    1:4);
X.block_id = [1:7,1:7,1:7,1:21]';
disp(X);