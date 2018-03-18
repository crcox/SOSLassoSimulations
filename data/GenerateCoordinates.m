function [coords, data] = GenerateCoordinates(d, SortIndex)
    subjects = categories(d.subject);
    example_id = categories(d.example_id);
    unit_categories = categories(d.unit_category);
    z = d.subject == subjects{1} & ...
        d.example_id == example_id{1};
	N = cell2struct( ...
        num2cell(countcats(d.unit_category(z))), ...
        categories(d.unit_category));
    N.subjects = numel(subjects);
    N.examples = numel(example_id);
    N.units = sum([N.SI,N.AI,N.SH,N.AH,N.SO,N.AO,N.noise,N.padding]);
    % One example, one subject
    D = d(z,:);
    conditions = categories(SortIndex.condition);
    
    [i,j] = ndgrid(1:numel(subjects),1:numel(conditions));
    coords = struct( ...
        'subject', num2cell(i(:)), ...
        'orientation', conditions(j(:)) , ...
        'ind', [], ...
        'ijk', [], ...
        'xyz', []);
    data = struct( ...
        'subject',num2cell(i(:)), ...
        'condition',conditions(j(:)), ...
        'X', []);
    for i = 1:numel(conditions)
        for j = 1:numel(subjects)
            z = SortIndex.subject == subjects{j} & ...
                SortIndex.condition == conditions{i};
            S = SortIndex(z,:);
            UC = unit_categories(countcats(S.unit_category)>0);
            z = ismember(D.unit_category, UC);
            index = D.padded_unit_id;
            index_uc = index(z);
            index(z) = index_uc(S.index);
            ijk = [index, D.padded_blocks, zeros(size(index))];

            z = d.subject == subjects{j};
            y = [data.subject] == j & strcmp(conditions{i}, {data.condition});
            
            coords(y).ind = index;
            coords(y).ijk = ijk;
            coords(y).xyz = ijk;
            data(y).X = reshape(d.activation(z), ...
                N.units, ...
                N.examples)';
        end
    end
        
    
    