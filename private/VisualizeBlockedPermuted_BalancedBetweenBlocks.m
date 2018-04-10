[ix,tmp] = generateBlockedPermuted(struct('SH',7,'AH',7,'noise',28,'subjects',10),'balance','between');
clear X;
for i = 1:10
    X(:,i) = tmp.unit_category(ix(:,i),:);
end
X = array2table(X);
X.block = ordinal( ...
     [repmat(4,7,1);ones(7,1);repmat(4,7,1);repmat(2,7,1);repmat(4,7,1);repmat(3,7,1)], ...
     {'Block 1','Block 2','Block 3','Gap'}, ...
     1:4);
X.block_id = repmat((1:7)',6,1);
disp(X);