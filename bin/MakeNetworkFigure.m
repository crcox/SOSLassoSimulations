function [ ] = MakeNetworkFigure( UnitCodes )
    base_prob = 0.1;
    p_threshold = 0.01;
    svgDOM = xmlread('C:\Users\mbmhscc4\GitHub\SOSLassoSimulations\template\ModelSchematic_ColorCoded.svg');
    nsubj = numel(categories(UnitCodes.subject));
    conditions = categories(UnitCodes.condition);
    variablesOfInterest = {'unit_category','unit_id_by_category','unit_contribution','padded_unit_id','condition'};
    [UnitCodesByCond,~,G] = unique(UnitCodes(:,variablesOfInterest));
    UnitCodesByCond.n_nz = splitapply(@nnz, UnitCodes.weights ~= 0, G);
    UnitCodesByCond.n_pos = splitapply(@nnz, UnitCodes.weights > 0, G);
    UnitCodesByCond.n_neg = splitapply(@nnz, UnitCodes.weights < 0, G);
    UnitCodesByCond.pval = binopdf(UnitCodesByCond.n_nz, nsubj, base_prob);
    UnitCodesByCond.rgb = [ ...
        UnitCodesByCond.n_pos./UnitCodesByCond.n_nz, ... % More red if more positive
        zeros(size(UnitCodesByCond,1),1), ...            % No green
        UnitCodesByCond.n_neg./UnitCodesByCond.n_nz];    % More blue if more negative
    z = isnan(UnitCodesByCond.rgb(:,1));
    hex = repmat({'#808080'},numel(z),1);
    hex(~z) = cellstr(rgb2hex(UnitCodesByCond.rgb(~z,:)));
    UnitCodesByCond.hex = hex;
    
    sig = UnitCodesByCond.pval < p_threshold;
    UnitCodesByCond.hex_sig = UnitCodesByCond.hex;
    UnitCodesByCond.hex_sig(~sig) = {'#808080'};
    
    UnitCodesByCond.hex = categorical(UnitCodesByCond.hex);
    UnitCodesByCond.hex_sig = categorical(UnitCodesByCond.hex_sig);
    
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

function UnitCode = getUnitCode(uc)
    UnitCode = sprintf('%s%s',uc.unit_category,uc.unit_id_by_category);
end