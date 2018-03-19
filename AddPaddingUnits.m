function D = AddPaddingUnits(d,groups,sz)
% ADDPADDINGUNITS Add units and reindex to isolate groups of units.
%
% This function does two things. First, it extends the representation for
% each example/subject to include enough padding units to fully isolate the
% number of groups provided (in this case, 3). This also extends the
% unit_id range, and because we are adding padding units last they will be
% associated with the highest unit_ids.
%
% Second, the function creates a new index, "padded_unit_id", which is a
% re-ordered version of unit_id where the padding units indexed so that the
% fall between the groups defined below, and such that sets of units that
% are grouped together have contiguous padded_unit_ids. In order words,
% while "unit_id" basically indexes in the order of addition to the
% AnnotatedData table, "padded_unit_id" will reflect and ordering of units
% that incorporates noise and padding into positions that are more
% meaningful for the subsequent simulations.
%
% (A second new variable, called "padded_blocks", is also created. It
% groups the units with respect to the GroupsToIsolate structure, and
% allocated the right amount of padding to each.)
	subjects = categories(d.subject);
    example_id = categories(d.example_id);
    z = d.subject == subjects{1} & ...
        d.example_id == example_id{1};
	N = cell2struct( ...
        num2cell(countcats(d.unit_category(z))), ...
        categories(d.unit_category));
    N.subjects = numel(subjects);
    N.examples = numel(example_id);

    ngroups = numel(groups);
    subjects = categories(d.subject);
    examples = categories(d.example_id);
    nPaddingUnits = (ngroups) * sz;
    
    [k,j,i] = ndgrid(1:nPaddingUnits,str2double(examples),str2double(subjects));  
    subject = categorical(i(:));
    example_id = categorical(j(:));
    example_category = categorical(j(:) > 36, [0,1], {'A','B'});
        unit_category = categorical( ...
        ones(numel(k),1) * 8, ...
        1:8, ...
        {'SI','AI','SH','AH','SO','AO','noise','padding'}, ...
        'Ordinal',true);
    unit_id_by_category = categorical(k(:));
    unit_id = categorical(k(:) + max(str2double(categories(d.unit_id))));
    unit_contribution = categorical(ones(numel(k),1),1,{'neither'});
    
    activation = zeros(numel(k), 1);
    padded_blocks = zeros(nPaddingUnits, 1);
    cur = sz / 2;
    for i = 1:numel(groups)
        a = cur + 1;
        if i == numel(groups)
            b = cur + (sz / 2);
        else
            b = cur + sz;
        end
        cur = b;
        padded_blocks(a:b) = i;
    end
    padded_blocks = repmat(padded_blocks, N.examples * N.subjects, 1);
    
    d.padded_blocks = zeros(size(d,1),1);
    for i = 1:numel(groups)
        z = ismember(d.unit_category, groups{i});
        d.padded_blocks(z) = i;
    end
    
    e = table( ...
        subject, ...
        example_category, ...
        example_id, ...
        unit_category, ...
        unit_id, ...
        unit_id_by_category, ...
        unit_contribution, ...
        padded_blocks, ...
        activation, ...
        'VariableNames',{
            'subject'
            'example_category'
            'example_id'
            'unit_category'
            'unit_id'
            'unit_id_by_category'
            'unit_contribution'
            'padded_blocks'
            'activation'
        });
	D = sortrows([d;e], {
        'subject'
        'example_category'
        'example_id'
        'padded_blocks'
        'unit_category'
        'unit_id'
        'unit_id_by_category'
        });
    
    MaxUnitID = max(str2double(categories(D.unit_id)));
    D.padded_unit_id = repmat((1:MaxUnitID)', N.examples * N.subjects, 1);
end
