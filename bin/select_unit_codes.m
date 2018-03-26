function UnitCodes = select_unit_codes(d, SortInfo, r)
    z = d.subject == num2str(r.subject) & ...
        d.example_id == '1';
    if r.nvox == 114
    	z = z & d.unit_category ~= 'padding';
    end
    UnitCodes = sortrows(d(z,:),'padded_unit_id');
    UnitCodes = apply_sort_to_unit_codes(UnitCodes,SortInfo);
end
