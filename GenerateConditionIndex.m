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
    
    %% Blocked Permuted Balanced
    z = SortIndex.condition == 'blocked permuted balanced';
    ix = generateBlockedPermuted(N);
    SortIndex.index(z) = ix(:);
    
end
