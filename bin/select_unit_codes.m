function UnitCodes = select_unit_codes(d, varargin)
    p = inputParser();
    addRequired(p, 'd', @istable);
    addParameter(p, 'subject', '1');
    addParameter(p, 'DropPadding', false, @islogical);
    parse(p, d, varargin{:});
    
    if isnumeric(p.Results.subject)
        s = num2str(p.Results.subject);
    else
        s = p.Results.subject;
    end
    z = d.subject == s & ...
        d.example_id == '1';
    if p.Results.DropPadding
    	z = z & d.unit_category ~= 'padding';
    end
    d.example_category = [];
    d.example_id = [];
    UnitCodes = sortrows(d(z,:),'padded_unit_id');
%     UnitCodes = apply_sort_to_unit_codes(UnitCodes,SortInfo);
end
