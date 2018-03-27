function [ style_struct ] = svg_split_style( style_string )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    style_split = reshape(strsplit(char(style_string),{':',';'}),2,[]);
    style_struct = struct('label', style_split(1,:), 'value', style_split(2,:));
end

