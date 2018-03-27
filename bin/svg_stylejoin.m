function [ style_string ] = svg_stylejoin( style_struct )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    style_cell = cell(1,numel(style_struct));
    for i = 1:numel(style_struct)
        style_cell{i} = strjoin({style_struct(i).label,svg_encodestylevalue(style_struct(i))},':');
    end
    style_string = strjoin(style_cell, ';');
end

function x = svg_encodestylevalue(s)
    switch s.label
        case {'stroke-width','stroke-miterlimit','stroke-dashoffset','stroke-opacity'}
            x = trim_trailing_zeros(sprintf('%.8f', s.value));
        otherwise
            x = s.value;
    end
end

function y = trim_trailing_zeros(x)
    y = regexprep(x,'\.?0+$','');
end