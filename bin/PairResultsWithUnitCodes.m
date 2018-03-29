function UnitCodes = PairResultsWithUnitCodes( Results, AnnotatedData )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    UCW = cell(numel(Results), 1);
    for i = 1:numel(Results);
        UnitCodes = select_unit_codes(AnnotatedData, 'DropPadding', Results(i).nvox==114);
        UnitCodes.condition = repmat({Results(i).condition}, size(UnitCodes,1),1);
        UnitCodes.weights = Results(i).Wz;
        UCW{i} = UnitCodes;
    end
    UnitCodes = cat(1,UCW{:});
    UnitCodes.condition = categorical(UnitCodes.condition);
end
