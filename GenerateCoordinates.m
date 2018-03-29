function [coords, data, filters] = GenerateCoordinates(d, SortIndex, varargin)
% GENERATECOORDINATES Compose coordinates based on 
%
    p = inputParser();
    addRequired(p, 'd');
    addRequired(p, 'SortIndex');
    addParameter(p, 'NoiseStrength', 1.0, @isscalar);
    parse(p, d, SortIndex, varargin{:});
    
    % Sorting is important because it will govern the order of columns in
    % data.X matrices. Note that the ordering is by the padded_unit_id!
	d = sortrows(d, {
        'subject'
        'example_category'
        'example_id'
        'padded_unit_id'
        });
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

            z = [coords.subject] == j & strcmp(conditions{i}, {coords.orientation});           
            coords(z).ind = index;
            coords(z).ijk = ijk;
            coords(z).xyz = ijk;
        end
    end
    data = struct( ...
        'subject',num2cell(1:10), ...
        'X', []);
    d = DistortSignal(d, p.Results.NoiseStrength);
    for i = 1:numel(subjects)
        z = d.subject == subjects{i};
        data(i).X = reshape(d.distorted_activation(z), ...
            N.units, ...
            N.examples)';
    end
    filters = struct( ...
        'subject', num2cell(1:10), ...
        'label', {'not_padding'}, ...
        'dimension', 2, ...
        'filter', []);
    for i = 1:numel(subjects)
        z = d.subject == subjects{i} & d.example_id == example_id{1};
        filters(i).filter = d.unit_category(z) ~= 'padding';
    end
end
