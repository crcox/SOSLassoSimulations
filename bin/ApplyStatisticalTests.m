function [ UnitCodesByCond ] = ApplyStatisticalTests( UnitCodesByCond, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addRequired(p, 'UnitCodes', @istable);
    addOptional(p, 'BaseProbability', table(), @istable);
    addParameter(p, 'Template', '../../../../template/ModelSchematic_ColorCoded.svg',@ischar);
    addParameter(p, 'PThreshold', 0.05, @isscalar);
    addParameter(p, 'AnalysisType', 'unspecified', @(x) any(strcmp(x,{'ridge','lasso','soslasso','univariate','searchlight'})));
    parse(p, UnitCodesByCond, varargin{:});
    
    splitapply_local = defineIfNotBuiltin('splitapply', @splitapply_crc);
    UnitCodes = merge_baseprobability(p.Results.UnitCodes,p.Results.BaseProbability);
    switch p.Results.AnalysisType
        case 'ridge'
            nsubj = numel(categories(UnitCodes.subject));
            variablesOfInterest = {'condition','subject'};
            [~,~,G] = unique(UnitCodes(:,variablesOfInterest));
            UnitCodes.isTopQuartile = cell2mat(splitapply_local(@isTopQuartile, UnitCodes.weights, G));
            variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition'};
            [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
            UnitCodesByCond.n_TopQuartile = splitapply_local(@nnz, UnitCodes.isTopQuartile, G);
            UnitCodesByCond.n_pos = splitapply_local(@nnz, UnitCodes.weights > 0, G);
            UnitCodesByCond.n_neg = splitapply_local(@nnz, UnitCodes.weights < 0, G);
            UnitCodesByCond.n_nz = UnitCodesByCond.n_pos + UnitCodesByCond.n_neg;
            f = floor(nsubj*0.25);
            UnitCodesByCond.pval = binopdf(max(UnitCodesByCond.n_TopQuartile,f), nsubj, 0.25);

        case 'univariate'
            UnitCodesByCond = UnitCodes;
            [~,~,~,UnitCodesByCond.pval] = fdr_bh(UnitCodes.pval);
            
        case 'searchlight'
            variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition','radius'};
            [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
            ttest_output = splitapply_local(@myttest, UnitCodes.accuracy - 0.5, G);
            UnitCodesByCond.pval = ttest_output(:,1);
            UnitCodesByCond.tstat = ttest_output(:,2);
            
        case {'lasso','soslasso'}
            nsubj = numel(categories(UnitCodes.subject));
            variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition'};
            [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
            UnitCodesByCond.baseprob = splitapply_local(@mean, UnitCodes.baseprob, G);
            UnitCodesByCond.n_nz = splitapply_local(@nnz, UnitCodes.weights ~= 0, G);
            UnitCodesByCond.n_pos = splitapply_local(@nnz, UnitCodes.weights > 0, G);
            UnitCodesByCond.n_neg = splitapply_local(@nnz, UnitCodes.weights < 0, G);
            f = floor(nsubj*UnitCodesByCond.baseprob);
            UnitCodesByCond.pval = binopdf(max(UnitCodesByCond.n_nz,f), nsubj, UnitCodesByCond.baseprob);
            
        case 'unspecified'
            error('An analysis type must be specified for the data to be properly prepared.')

    end
end

function m = merge_baseprobability(uc,bp)
    m = uc;
    if ~isempty(bp)
        m.baseprob = nan(size(m,1),1);
        if isfield(bp,'median')
            m.median = m.baseprob;
        end
        [ucu,~,ib] = unique(uc(:,{'subject','condition'}));
        assert(size(ucu,1)==size(bp,1));
        for i = 1:size(ucu,1)
            z = ib == i;
            m.baseprob(z) = bp.baseprob(i,:)';
            if isfield(bp,'median')
                m.median(z) = bp.median(i,:)';
            end
            
        end
    end
end

function y = myttest(x,varargin)
    [~,pval,~,stats] = ttest(x,varargin{:});
    tstat = stats.tstat;
    y = [pval,tstat];
end

function b = isTopQuartile(w)
    q = quantile(w,0.75);
    b = {w(:) >= q};
end