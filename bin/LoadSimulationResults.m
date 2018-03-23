function R = LoadSimulationResults( path , varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addRequired(p, 'path', @(x) ischar(x) || (iscellstr(x) && numel(x)==1));
    addParameter(p, 'AsTable', false, @(x) islogical(x) || any(x==[0,1]));
    parse(p, path, varargin{:});

    [P,R,nperjob] = HTCondorLoad(p.Results.path);
    cur = 0;
    for i = 1:numel(nperjob)
        a = cur + 1;
        b = cur + nperjob(i);
        cur = b;
        [R(a:b).condition] = deal(P(i).orientation);
        if strcmp(P(i).regularization,'soslasso')
            [R(a:b).diameter] = deal(P(i).diameter);
            [R(a:b).overlap] = deal(P(i).overlap);
        end
    end
    if p.Results.AsTable
        R = struct2table(R);
    end
end

