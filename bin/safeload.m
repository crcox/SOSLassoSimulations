function [ x ] = safeload( f, v )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    tmp = load(f,v);
    x = tmp.(v);
end

