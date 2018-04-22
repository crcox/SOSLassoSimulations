function [UnitCodes,summary] = PairResultsWithUnitCodes( Results, AnnotatedData, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addRequired(p, 'Results', @isstruct);
    addRequired(p, 'AnnotatedData', @istable);
    addParameter(p, 'VariableToPair', 'Wz');
    addParameter(p, 'NewVariableName', 'weights');
    parse(p, Results, AnnotatedData, varargin{:});
    
    UCW = cell(numel(Results), 1);
    for i = 1:numel(Results);
        UnitCodes = select_unit_codes(AnnotatedData, 'subject', Results(i).subject, 'DropPadding', ~strcmp(Results(i).AnalysisType,'searchlight'));
        UnitCodes.condition = repmat({Results(i).condition}, size(UnitCodes,1),1);
        if isfield(Results,'radius')
            UnitCodes.radius = repmat(Results(i).radius, size(UnitCodes,1),1);
        end
%         z = ismember(UnitCodes.unit_category, {'SO','AO'});
%         UnitCodes(z,:) = [];
        UnitCodes.(p.Results.NewVariableName) = forcecolvec(Results(i).(p.Results.VariableToPair));
        if strcmp(Results(i).AnalysisType,'searchlight')
            z = UnitCodes.unit_category == 'padding';
            UnitCodes = UnitCodes(~z,:);
        end
        UCW{i} = UnitCodes;
    end
    UnitCodes = cat(1,UCW{:});
    UnitCodes.condition = categorical(UnitCodes.condition);
    summary = summary_table(UnitCodes, p.Results.NewVariableName);
    
    disp(summary);
end

function t = summary_table(WeightTable, varname)
    absvar = sprintf('abs_%s', varname);
    nzvar = sprintf('nz_%s', varname);
    WeightTable.(absvar) = abs(WeightTable.(varname));
    WeightTable.(nzvar) = WeightTable.(varname) ~= 0;
    if any(strcmp('radius',WeightTable.Properties.VariableNames))
        groupby = {'condition','radius','unit_category','unit_contribution'};
    else
        groupby = {'condition','unit_category','unit_contribution'};
    end
    allvars = [groupby,{absvar,nzvar}];
    t = grpstats(WeightTable(:,allvars),groupby);
end
