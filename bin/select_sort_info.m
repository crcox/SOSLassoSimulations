function SortInfo = select_sort_info(ci, r)
    z = ci.condition == r.condition & ...
        ci.subject == num2str(r.subject);
    SortInfo = ci(z,:);
end

