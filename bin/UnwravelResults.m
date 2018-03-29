function UnitCodes = UnwravelResults( ResultsDir, AnnotatedData, ConditionIndex )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    results = LoadSimulationResults( ResultsDir );
    UCW = cell(numel(results), 1);
    for i = 1:numel(results);
        SortInfo = select_sort_info(ConditionIndex, results(i));
        UnitCodes = select_unit_codes(AnnotatedData, SortInfo, results(i));
        UnitCodes.weights = results(1).Wz;
        UCW{i} = UnitCodes;
    end
    UnitCodes = cat(1,UCW{:});
end
    