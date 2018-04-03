function [ ] = GenerateFigures_SEARCHLIGHT( varargin )
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
    final = LoadSimulationResults('final','searchlight');
    unitcodes_final = PairResultsWithUnitCodes( final, AnnotatedData, ...
        'VariableToPair', 'accuracy_map', 'NewVariableName', 'accuracy');

    UnitCodesByCond = ApplyStatisticalTests(unitcodes_final, 'AnalysisType', 'searchlight');
    writetable(UnitCodesByCond, 'UnitCodesByCond.csv');
    MakeNetworkFigure(UnitCodesByCond,'PThreshold', alpha, 'FDRCorrect', fdr, 'AnalysisType', 'searchlight');
    
    TPFP = cell(2,1);
    z = UnitCodesByCond.radius == 2;
    TPFP{1} = TruePosFalsePos(UnitCodesByCond(z,:),'PThreshold', alpha, 'FDRCorrect', fdr);
    TPFP{1}.radius = repmat(2,size(TPFP{1},1),1);
    figure(10)
    MakeSensitivityFigure(TPFP{1});
    z = UnitCodesByCond.radius == 14;
    TPFP{2} = TruePosFalsePos(UnitCodesByCond(z,:),'PThreshold', alpha, 'FDRCorrect', fdr);
    TPFP{2}.radius = repmat(14,size(TPFP{2},1),1);
    figure(20)
    MakeSensitivityFigure(TPFP{2});
    TPFP = cat(1,TPFP{:});
    writetable(UnitCodesByCond, 'TPFP.csv');
end
