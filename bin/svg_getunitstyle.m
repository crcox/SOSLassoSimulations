function style_struct = svg_getunitstyle(unit)
    style_string = unit.getAttribute('style');
    style_struct = svg_stylesplit(style_string);
end