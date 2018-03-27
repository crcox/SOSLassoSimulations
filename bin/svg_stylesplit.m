function [ style_struct ] = svg_stylesplit( style_string )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    style_split = reshape(strsplit(char(style_string),{':',';'}),2,[]);
    style_struct = struct('label', style_split(1,:), 'value', style_split(2,:));
    for i = 1:numel(style_struct)
        style_struct(i).value = svg_decodestylevalue(style_struct(i));
    end
end

function x = svg_decodestylevalue(s)
    switch s.label
        case {'stroke-width','stroke-miterlimit','stroke-dashoffset','stroke-opacity'}
            x = str2double(s.value);
        otherwise
            x = s.value;
    end
end