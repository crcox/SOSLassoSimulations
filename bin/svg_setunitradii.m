function unit = svg_setunitradii(unit, radii)
    unit.setAttribute('rx', sprintf('%.8f',radii(1)));
    unit.setAttribute('ry', sprintf('%.8f',radii(2)));
end
