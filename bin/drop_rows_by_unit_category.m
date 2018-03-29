function d = drop_rows_by_unit_category(d, category_to_drop)
    if any(ismember(category_to_drop, categories(d.unit_category)))
        z = ~ismember(d.unit_category,category_to_drop);
        d = d(z,:);
    else
        error('Invalid unit category: %s.', category_to_drop);
    end
end
