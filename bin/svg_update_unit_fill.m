function svg_update_unit_fill( svgDOM, unitID, fill )
%SVG_UPDATE_UNIT_FILL Update fill of specified unit
%   The svgDOM is passed my reference, and modifications have global scope.
%   This function has no return value, because its effects on the DOM are
%   realized even they are executed within subfunctions.
    unit_list = svgDOM.getElementsByTagName('ellipse');
    unit = svg_selectunit(unit_list, unitID);
    unit_style = svg_getunitstyle(unit);
    unit_style = svg_setfill(unit_style, fill);
    svg_setunitstyle(unit, unit_style);
end

function style_struct = svg_setfill(style_struct, fill)
    z = strcmp('fill', {style_struct.label});
    if iscategorical(fill)
        style_struct(z).value = char(fill);
    else
        style_struct(z).value = fill;
    end
end




