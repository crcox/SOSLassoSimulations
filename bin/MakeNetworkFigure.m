function [ ] = MakeNetworkFigure( UnitCodes, varargin)
    p = inputParser();
    addRequired(p, 'UnitCodes', @istable);
    addOptional(p, 'BaseProbability', table(), @istable);
    addParameter(p, 'Template', '../../../../template/ModelSchematic_ColorCoded.svg',@ischar);
    addParameter(p, 'PThreshold', 0.01, @isscalar);
    parse(p, UnitCodes, varargin{:});
    
    splitapply_local = defineIfNotBuiltin('splitapply', @splitapply_crc);
    UnitCodes = merge_baseprobability(p.Results.UnitCodes,p.Results.BaseProbability);
    isSearchlight = any(strcmp('radius',UnitCodes.Properties.VariableNames));
    isUnivariate = any(strcmp('lme',UnitCodes.Properties.VariableNames));
    
    svgDOM = xmlread(p.Results.Template);
    if isSearchlight
        variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition','radius'};
        [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
        ttest_output = splitapply_local(@myttest, UnitCodes.accuracy - 0.5, G);
        [~,~,~,UnitCodesByCond.pval] = fdr_bh(ttest_output(:,1),p.Results.PThreshold);
        UnitCodesByCond.tstat = ttest_output(:,2);
        UnitCodesByCond.rgb = generate_rgb_searchlight(UnitCodesByCond);
    elseif isUnivariate
        UnitCodesByCond = UnitCodes;
        [~,~,~,UnitCodesByCond.pval] = fdr_bh(UnitCodes.pval);
        UnitCodesByCond.rgb = generate_rgb_univariate(UnitCodesByCond);        
    else
        nsubj = numel(categories(UnitCodes.subject));
        variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition'};
        [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
        UnitCodesByCond.baseprob = splitapply_local(@mean, UnitCodes.baseprob, G);
        UnitCodesByCond.n_nz = splitapply_local(@nnz, UnitCodes.weights ~= 0, G);
        UnitCodesByCond.n_pos = splitapply_local(@nnz, UnitCodes.weights > 0, G);
        UnitCodesByCond.n_neg = splitapply_local(@nnz, UnitCodes.weights < 0, G);
        UnitCodesByCond.pval = binopdf(UnitCodesByCond.n_nz, nsubj, UnitCodesByCond.baseprob);
        UnitCodesByCond.rgb = generate_rgb_lasso(UnitCodesByCond);
    end
    
    UnitCodesByCond.hex = generate_hex(UnitCodesByCond);
    UnitCodesByCond.hex_sig = generate_hex(UnitCodesByCond, p.Results.PThreshold);
    
    if isSearchlight
        generate_figures_searchlight(svgDOM, UnitCodesByCond)
    elseif isUnivariate
        generate_figures_univariate(svgDOM, UnitCodesByCond)
    else
        generate_figures_wholebrain_mvpa(svgDOM, UnitCodesByCond, nsubj)
    end

end

function UnitCode = getUnitCode(uc)
    UnitCode = sprintf('%s%s',char(uc.unit_category),char(uc.unit_id_by_category));
end

function rgb = generate_rgb_univariate(UnitCodesByCond)
    r = UnitCodesByCond.tstat > 0 + 0;
    b = UnitCodesByCond.tstat <= 0 + 0;
    g = zeros(numel(b),1);
    rgb = [r,g,b];
end

function rgb = generate_rgb_lasso(UnitCodesByCond)
    % More red if more positive
    % More blue if more negative
    % Green intensifies as ratio between red and blue approaches 1.
    % Green will be zero if all positive or all negative.
    r = UnitCodesByCond.n_pos./UnitCodesByCond.n_nz;
    b = UnitCodesByCond.n_neg./UnitCodesByCond.n_nz;
    g = r./b;
    g(g>1) = b(g>1)./r(g>1);
    rgb = [r,g,b];
end

function rgb = generate_rgb_searchlight(UnitCodesByCond)
    % No red
    % No blue
    % Green intensifies as tstat increases
    g = min(abs(UnitCodesByCond.tstat)/9, 1);
    r = zeros(numel(g),1);
    b = zeros(numel(g),1);
    rgb = [r,g,b];
end

function hex = generate_hex(UnitCodesByCond, PThreshold)
    GREYHEX = '#808080';
    z = isnan(UnitCodesByCond.rgb(:,1));
    hex = repmat({GREYHEX},numel(z),1);
    hex(~z) = cellstr(rgb2hex(UnitCodesByCond.rgb(~z,:)));
    if nargin == 2
        sig = UnitCodesByCond.pval < PThreshold;
        hex(~sig) = {GREYHEX};
    end
    hex = categorical(hex);
end

function [] = generate_figures_univariate(svgDOM, UnitCodesByCond)
    conditions = categories(UnitCodesByCond.condition);
    for j = 1:numel(conditions)
        z = UnitCodesByCond.condition == conditions{j};
        uc = UnitCodesByCond(z,:);
        for i = 1:size(uc, 1)
            UnitCode = getUnitCode(uc(i,:));
            svg_update_unit_fill(svgDOM,UnitCode,uc.hex_sig(i));
        end
        xmlwrite(sprintf('%s.svg',conditions{j}), svgDOM);
    end
end

function [] = generate_figures_wholebrain_mvpa(svgDOM, UnitCodesByCond, nsubj)
    conditions = categories(UnitCodesByCond.condition);
    for j = 1:numel(conditions)
        z = UnitCodesByCond.condition == conditions{j};
        uc = UnitCodesByCond(z,:);
        for i = 1:size(uc, 1)
            UnitCode = getUnitCode(uc(i,:));
            svg_update_unit_fill(svgDOM,UnitCode,uc.hex_sig(i));
            svg_update_unit_scale(svgDOM,UnitCode,uc.n_nz(i)/nsubj);
        end
        xmlwrite(sprintf('%s.svg',conditions{j}), svgDOM);
    end
end

function [] = generate_figures_searchlight(svgDOM, UnitCodesByCond)
    conditions = categories(UnitCodesByCond.condition);
    radii = unique(UnitCodesByCond.radius);
    for k = 1:numel(radii)
        for j = 1:numel(conditions)
            z = UnitCodesByCond.condition == conditions{j} & ...
                UnitCodesByCond.radius == radii(k);
            uc = UnitCodesByCond(z,:);
            for i = 1:size(uc, 1)
                UnitCode = getUnitCode(uc(i,:));
                svg_update_unit_fill(svgDOM,UnitCode,uc.hex_sig(i));
            end
            xmlwrite(sprintf('%s_radius%d.svg',conditions{j},radii(k)), svgDOM);
        end
    end
end

function m = merge_baseprobability(uc,bp)
    if isempty(bp)
        m = uc;
    else
        m = join(uc,bp);
    end
end

function y = myttest(x,varargin)
    [~,pval,~,stats] = ttest(x,varargin{:});
    tstat = stats.tstat;
    y = [pval,tstat];
end