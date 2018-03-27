function [ output_args ] = svg_update_unit_scale( svgDOM, unitID, scale )
    unit_list = svgDOM.getElementsByTagName('ellipse');
    unit = svg_selectunit(unit_list, unitID);
    [rx,ry] = svg_getunitradii(unit);
    svg_setunitradii(unit, [rx,ry] .* scale);
end
