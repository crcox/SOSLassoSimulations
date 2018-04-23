function [ x ] = TruePosFalsePos( UnitCodesByCond, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addRequired(p, 'UnitCodesByCond', @istable);
    addParameter(p, 'PThreshold', 0.05, @isscalar);
    addParameter(p, 'FDRCorrect', true, @islogical);
    parse(p, UnitCodesByCond, varargin{:});
    
    if p.Results.FDRCorrect
        [~,~,~,UnitCodesByCond.pval] = fdr_bh(UnitCodesByCond.pval,p.Results.PThreshold);
    end
    
    splitapply_local = defineIfNotBuiltin('splitapply', @splitapply_crc);
    x = ismember(UnitCodesByCond.unit_category,{'SI','AI','SO','AO'})*1;
    y = ismember(UnitCodesByCond.unit_category,{'SH','AH','noise'})*2;
    UnitCodesByCond.layer = categorical(x+y, 1:2, {'input/output','hidden'});
    [x,~,g] = unique(UnitCodesByCond(:, {'condition','layer','radius'}));
    % For custom split apply
%     f = @(x) tpfp(x.layer,x.unit_category,x.pval,p.Results.PThreshold);
    % For builtin split apply
    f = @(layer,unit_category,pval) tpfp(layer,unit_category,pval,p.Results.PThreshold);
    tmp = splitapply_local(f, UnitCodesByCond(:,{'layer','unit_category','pval'}), g);
    try % with builtin split apply
        tmp = cell2mat(tmp);
    catch % with custom split apply
        tmp = cell2mat(cat(1,tmp{:}));
    end
    x.tp = tmp(:,1);
    x.fp = tmp(:,2);
    x.np = tmp(:,3);
    x.nn = tmp(:,4);
end

function y = tpfp(layer,unit_category,pval,alpha)
    switch layer(1)
        case 'input/output'
            np = nnz(ismember(unit_category,{'SI','SO'}));
            nn = nnz(ismember(unit_category,{'AI','AO'}));
            tp = nnz(ismember(unit_category,{'SI','SO'}) & (pval < alpha));
            fp = nnz(ismember(unit_category,{'AI','AO'}) & (pval < alpha));
        case 'hidden'
            np = nnz(unit_category == 'SH');
            nn = nnz(ismember(unit_category,{'AH','noise'}));
            tp = nnz((unit_category == 'SH') & (pval < alpha));
            fp = nnz(ismember(unit_category,{'AH','noise'}) & (pval < alpha));
    end
    y = {[tp,fp,np,nn]};
end