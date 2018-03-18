function SortIndex = GenerateConditionIndex(d)
%% Setup
	subjects = categories(d.subject);
    example_id = categories(d.example_id);
    z = d.subject == subjects{1} & ...
        d.example_id == example_id{1} & ...
        ismember(d.unit_category, {'SH','AH','noise'});
	N = cell2struct( ...
        num2cell(countcats(d.unit_category(z))), ...
        categories(d.unit_category));
    N.subjects = numel(subjects);
    
    % There are 5 conditions, so replicate selction 5 times.
    z = d.example_id == example_id{1} & ...
        ismember(d.unit_category, {'SH','AH','noise'});
    SortIndex = repmat(d(z,{
        'subject'
        'unit_category'
        'unit_id'
        'unit_id_by_category'
        'unit_contribution'
        }), 5, 1);
    SortIndex.condition = categorical( ...
        reshape(repmat(1:5,nnz(z),1), nnz(z)*5, 1), ...
        1:5, ...
        {'local','permuted','interleaved','blocked interleaved','blocked permuted'});
    SortIndex.index = nan(size(SortIndex,1),1);
    
    %% Local
    z = SortIndex.condition == 'local';
    ix = generateLocal(N);
    SortIndex.index(z) = ix(:);
    
    %% Permuted
    z = SortIndex.condition == 'permuted';
    ix = generatePermuted(N);
    SortIndex.index(z) = ix(:);
    
    %% Interleaved
    z = SortIndex.condition == 'interleaved';
    ix = generateInterleaved(N);
    SortIndex.index(z) = ix(:);
    
    %% Blocked Interleaved
    z = SortIndex.condition == 'blocked interleaved';
    ix = generateBlockedInterleaved(N);
    SortIndex.index(z) = ix(:);
    
    %% Blocked Permuted
    z = SortIndex.condition == 'blocked permuted';
    ix = generateBlockedPermuted(N);
    SortIndex.index(z) = ix(:);
    
end

function ix = generateLocal(N)
    n = sum([N.SH,N.AH,N.noise]);
    ix = repmat((1:n)',1,N.subjects);
end

function ix = generatePermuted(N)
    n = sum([N.SH,N.AH,N.noise]);
    ix = zeros(n, N.subjects);
    for ss=1:N.subjects
        ix(:,ss) = randperm(n);
    end
end

function ix = generateInterleaved(N)
    unit_id_by_category = [1:N.SH,1:N.AH,1:N.noise];
    [~,ix] = sort(mod(unit_id_by_category - 1, N.SH));
    ix = repmat(ix,1,N.subjects);
end

function ix = generateBlockedInterleaved(N)
    tmp = table( ...
        categorical(...
            [repmat(1, N.SH, 1); ...
            repmat(2, N.AH, 1); ...
            repmat(3, N.noise, 1)], 1:3, {'SH','AH','noise'}), ...
        [1:N.SH,1:N.AH,1:N.noise]', ...
        'VariableNames', {'unit_category','unit_id_by_category'}); %#ok<RPMT1>
    UC = {'SH','AH','noise'};
    tmp.tmp = zeros(size(tmp,1),1);
    for i = 1:numel(UC)
        uc = UC{i};
        z = tmp.unit_category==uc;
        x = tmp.unit_id_by_category(z);
        if strcmp(uc, 'noise')
            tmp.tmp(z) = mod(x - 1, 4);
        else
            tmp.tmp(z) = mod(x - 1, 3) + 1;
        end
    end
    [~,ix] = sortrows(tmp, {'tmp','unit_category','unit_id_by_category'});
    ix = repmat(ix,1,N.subjects);
end

function ix = generateBlockedPermuted(N)
    tmp = table( ...
        categorical(...
            [repmat(1, N.SH, 1); ...
            repmat(2, N.AH, 1); ...
            repmat(3, N.noise, 1)], 1:3, {'SH','AH','noise'}), ...
        [1:N.SH,1:N.AH,1:N.noise]', ...
        'VariableNames', {'unit_category','unit_id_by_category'}); %#ok<RPMT1>

    UC = {'SH','AH','noise'};
    tmp.tmp1 = zeros(size(tmp,1),1);
    tmp.tmp2 = zeros(size(tmp,1),1);
    tmp.tmp3 = zeros(size(tmp,1),1);
    for i = 1:numel(UC)
        uc = UC{i};
        z = tmp.unit_category==uc;
        x = tmp.unit_id_by_category(z);
        tmp.tmp1(z) = mod(x - 1, 3);
    end
    for j = 0:2
        n = nnz(tmp.unit_category=='SH' & tmp.tmp1 == j);
        for i = 1:numel(UC)
            uc = UC{i};
            z = tmp.unit_category==uc & tmp.tmp1 == j;
            z(z) = [true(n,1); false(nnz(z)-n,1)];
            tmp.tmp2(z) = 1;
        end
    end
    % Generate different permutation for each subject, within
    % blocked constraints
    n = sum([N.SH,N.AH,N.noise]);
    ix = zeros(n, N.subjects);
    for j = 1:N.subjects
        for i = 0:2
            z = tmp.tmp1 == i & tmp.tmp2 == 1;
            n = nnz(z);
            tmp.tmp3(z) = randperm(n);
        end
        [~,ix(:,j)] = sortrows(tmp, {'tmp1','tmp3'});
    end
end