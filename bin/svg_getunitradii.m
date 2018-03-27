function [rx,ry] = svg_getunitradii(unit)
    rx = str2double(unit.getAttribute('rx'));
    ry = str2double(unit.getAttribute('ry'));
end
