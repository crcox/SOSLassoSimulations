function UnitCodes = select_unit_codes(d, varargin)
    p = inputParser();
    addRequired(p, 'd', @istable);
    addParameter(p, 'DropPadding', false, @islogical);
    parse(p, d, varargin{:});
    
    z = d.subject == '1' & ...
        d.example_id == '1';
    if p.Results.DropPadding
    	z = z & d.unit_category ~= 'padding';
    end
    UnitCodes = sortrows(d(z,:),'padded_unit_id');
%     UnitCodes = apply_sort_to_unit_codes(UnitCodes,SortInfo);
end
