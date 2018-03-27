function [u,i] = svg_selectunit(unit_list, unitID)
    unitID_list = arrayfun(@(i) char(unit_list.item(i).getAttribute('id')), ...
        0:(unit_list.getLength-1), ...
        'UniformOutput', 0);
    z = strcmp(unitID, unitID_list);
    i = find(z) - 1;
    u = unit_list.item(i);
end