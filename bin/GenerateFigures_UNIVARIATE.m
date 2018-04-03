function [ ] = GenerateFigures_UNIVARIATE( varargin )
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
    tmp = load( 'ModelTable.mat', 'ModelTable');
    unitcodes_final = tmp.ModelTable;

    UnitCodesByCond = ApplyStatisticalTests(unitcodes_final, 'AnalysisType', 'univariate');
    writetable(UnitCodesByCond, 'UnitCodesByCond.csv');
    MakeNetworkFigure(UnitCodesByCond,'PThreshold', alpha, 'FDRCorrect', fdr, 'AnalysisType', 'univariate');
    
    TPFP = TruePosFalsePos(UnitCodesByCond,'PThreshold', alpha, 'FDRCorrect', fdr);
    writetable(UnitCodesByCond, 'TPFP.csv');
    MakeSensitivityFigure(TPFP);
end

