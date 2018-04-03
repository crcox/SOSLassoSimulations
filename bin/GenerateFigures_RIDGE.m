function [ ] = GenerateFigures_RIDGE( varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser();
    addParameter(p, 'AnnotatedData', '../../../../data/AnnotatedData.mat', @ischar);
    addParameter(p, 'PThreshold', 0.05, @isscalar);
    addParameter(p, 'FDRCorrect', true, @islogical);
    parse(p, varargin{:});
    
    alpha = p.Results.PThreshold;
    fdr = p.Results.FDRCorrect;
    
    load('../../../../data/AnnotatedData.mat','AnnotatedData');
    final = LoadSimulationResults( 'final' );
    unitcodes_final = PairResultsWithUnitCodes(final,AnnotatedData);
    
    UnitCodesByCond = ApplyStatisticalTests(unitcodes_final, 'AnalysisType', 'ridge');
    writetable(UnitCodesByCond, 'UnitCodesByCond.csv');
    MakeNetworkFigure(UnitCodesByCond,'PThreshold', alpha, 'FDRCorrect', fdr, 'AnalysisType', 'ridge');
    
    TPFP = TruePosFalsePos(UnitCodesByCond,'PThreshold', alpha, 'FDRCorrect', fdr);
    writetable(UnitCodesByCond, 'TPFP.csv');
    MakeSensitivityFigure(TPFP);
end

