function R = LoadSimulationResults( ResultsDir , varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addRequired(p, 'ResultsDir', @(x) ischar(x) || (iscellstr(x) && numel(x)==1));
    addOptional(p, 'type', 'wholebrain_mvpa', @ischar);
    addParameter(p, 'AsTable', false, @(x) islogical(x) || any(x==[0,1]));
    parse(p, ResultsDir, varargin{:});

    switch p.Results.type
        case 'searchlight'
            [P,R,nperjob] = SearchlightLoad(p.Results.ResultsDir);
            [R.AnalysisType] = deal('searchlight');
        otherwise
            try
                [P,R,nperjob] = HTCondorLoad(p.Results.ResultsDir);
                [R.AnalysisType] = deal('wholebrain_mvpa');
            catch ME
                disp('LOAD FAILED: If you are attempting to load Searchlight results, set ''type'',''seachlight''.');
                rethrow(ME);
            end
    end
    cur = 0;
    for i = 1:numel(nperjob)
        a = cur + 1;
        b = cur + nperjob(i);
        cur = b;
        [R(a:b).condition] = deal(P(i).orientation);
        if isfield(P,'regularization') && strcmp(P(i).regularization,'soslasso')
            if isfield(P,'sosgroups') && ~isempty(P(i).sosgroups)
                [R(a:b).sosgroups] = deal(P(i).sosgroups);
            elseif isfield(P,'diameter') && ~isempty(P(i).diameter)
                [R(a:b).diameter] = deal(P(i).diameter);
                [R(a:b).overlap] = deal(P(i).overlap);
                [R(a:b).shape] = deal(P(i).shape);
            end
        end
    end
    if p.Results.AsTable
        R = struct2table(R);
    end
end

function [P,R,nperjob] = SearchlightLoad(ResultsDir)
    joblist = HTCondorListJobDirs(ResultsDir);
    tmp = cellfun(@(x) safeload(fullfile(ResultsDir,x,'results.mat'),'results'), joblist, 'UniformOutput', false);
    nperjob = cellfun(@numel,tmp);
    R = cat(2,tmp{:})';
    for i = 1:numel(R)
        R(i).nvox = numel(R(i).accuracy_map);
    end
    P = cellfun(@(x) loadjson(fullfile(ResultsDir,x,'params.json')), joblist, 'UniformOutput', true);
end