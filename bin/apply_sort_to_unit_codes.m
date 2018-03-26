function UnitCodes = apply_sort_to_unit_codes(UnitCodes,SortInfo)
    unit_categories = categories(SortInfo.unit_category);
    uc = unit_categories(countcats(SortInfo.unit_category)>0);
    z = ismember(UnitCodes.unit_category, uc);
    tmp = UnitCodes(z,:);
    UnitCodes(z,:) = tmp(SortInfo.index,:);
    UnitCodes.condition = repmat(SortInfo.condition(1),size(UnitCodes,1),1);
end