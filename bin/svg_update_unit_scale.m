function [rx,ry] = svg_update_unit_scale( svgDOM, unitID, scale, method )
    if nargin < 4
        method = 'proportional';
    end
    unit_list = svgDOM.getElementsByTagName('ellipse');
    unit = svg_selectunit(unit_list, unitID);
    [rx,ry] = svg_getunitradii(unit);
    switch method
        case 'proportional'
            if scale ~= 1
                svg_setunitradii(unit, [rx,ry] .* scale);
            end
        case 'absolute'
            svg_setunitradii(unit, scale);
    end
end
