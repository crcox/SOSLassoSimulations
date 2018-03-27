function unit = svg_setunitstyle(unit, style_struct)
    style_string = svg_stylejoin(style_struct);
    unit.setAttribute('style', style_string);
end