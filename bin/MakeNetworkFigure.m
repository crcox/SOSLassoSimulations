function [UnitCodesByCond] = MakeNetworkFigure( UnitCodesByCond, varargin)
    p = inputParser();
    addRequired(p, 'UnitCodes', @istable);
    addOptional(p, 'BaseProbability', table(), @istable);
    addParameter(p, 'Template', '../../../../template/ModelSchematic_ColorCoded.svg',@ischar);
    addParameter(p, 'PThreshold', 0.05, @isscalar);
    addParameter(p, 'FDRCorrect', true, @islogical);
    addParameter(p, 'AnalysisType', 'unspecified', @(x) any(strcmp(x,{'ridge','lasso','soslasso','univariate','searchlight'})));
    parse(p, UnitCodesByCond, varargin{:});
    
    if p.Results.FDRCorrect
        [~,crit_p,~,UnitCodesByCond.pval] = fdr_bh(UnitCodesByCond.pval,p.Results.PThreshold);
    end

    nsubj = 10;
    svgDOM = xmlread(p.Results.Template);
    switch p.Results.AnalysisType
        case 'ridge'
            UnitCodesByCond.rgb = generate_rgb_lasso(UnitCodesByCond);
            UnitCodesByCond.hex = generate_hex(UnitCodesByCond);
            UnitCodesByCond.hex_sig = generate_hex(UnitCodesByCond, p.Results.PThreshold);
            generate_figures_wholebrain_mvpa(svgDOM, UnitCodesByCond, nsubj)

        case 'univariate'
            UnitCodesByCond.rgb = generate_rgb_univariate(UnitCodesByCond);
            UnitCodesByCond.hex = generate_hex(UnitCodesByCond);
            UnitCodesByCond.hex_sig = generate_hex(UnitCodesByCond, p.Results.PThreshold);
            generate_figures_univariate(svgDOM, UnitCodesByCond)
            
        case 'searchlight'
            crit_t = tinv(crit_p, 9);
            UnitCodesByCond.rgb = generate_rgb_searchlight(UnitCodesByCond,crit_t);
            UnitCodesByCond.hex = generate_hex(UnitCodesByCond);
            UnitCodesByCond.hex_sig = generate_hex(UnitCodesByCond, p.Results.PThreshold);
            generate_figures_searchlight(svgDOM, UnitCodesByCond)
            
        case {'lasso','soslasso'}
            UnitCodesByCond.rgb = generate_rgb_lasso(UnitCodesByCond);
            UnitCodesByCond.hex = generate_hex(UnitCodesByCond);
            UnitCodesByCond.hex_sig = generate_hex(UnitCodesByCond, p.Results.PThreshold);
            generate_figures_wholebrain_mvpa(svgDOM, UnitCodesByCond, nsubj)
            
        case 'unspecified'
            error('An analysis type must be specified for the data to be properly prepared.')

    end
end

function UnitCode = getUnitCode(uc)
    UnitCode = sprintf('%s%s',char(uc.unit_category),char(uc.unit_id_by_category));
end

function rgb = generate_rgb_univariate(UnitCodesByCond)
    % Positive effects are voting for B
    r = UnitCodesByCond.tstat <= 0 + 0;
    b = UnitCodesByCond.tstat > 0 + 0;
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

function rgb = generate_rgb_searchlight(UnitCodesByCond, minT)
    % No red
    % No blue
    % Green intensifies as tstat increases
    x = max(UnitCodesByCond.tstat-minT,0); % set T <= minT to zero
    g = min(x/(9-minT), 1);
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
    OriginalScales = svg_get_original_unit_scales(svgDOM, UnitCodesByCond);
    for j = 1:numel(conditions)
        z = UnitCodesByCond.condition == conditions{j};
        uc = UnitCodesByCond(z,:);
        for i = 1:size(uc, 1)
            UnitCode = getUnitCode(uc(i,:));
            svg_update_unit_fill(svgDOM,UnitCode,uc.hex_sig(i));
            svg_update_unit_scale(svgDOM,UnitCode,OriginalScales(i,:),'absolute');
            svg_update_unit_scale(svgDOM,UnitCode,uc.n_nz(i)/nsubj,'proportional');
        end
        xmlwrite(sprintf('%s.svg',conditions{j}), svgDOM);
    end
end

function OriginalScales = svg_get_original_unit_scales(svgDOM, UnitCodesByCond)
    z = UnitCodesByCond.condition == UnitCodesByCond.condition(1);
    uc = UnitCodesByCond(z,:);
    OriginalScales = zeros(nnz(z),2);
    for i = 1:size(uc, 1)
        UnitCode = getUnitCode(uc(i,:));
        [rx,ry] = svg_update_unit_scale(svgDOM,UnitCode,1);
        OriginalScales(i,:) = [rx,ry];
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
