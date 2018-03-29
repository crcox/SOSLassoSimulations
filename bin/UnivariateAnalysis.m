function [ ModelTable, summary ] = UnivariateAnalysis( AnnotatedData, ConditionIndex )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    AnnotatedData = apply_conditional_sort(AnnotatedData, ConditionIndex);
    AnnotatedData = DistortSignal(AnnotatedData, 1.0);
    AnnotatedData.activation = smooth_activation_vector(AnnotatedData);
    AnnotatedData = drop_rows_by_unit_category(AnnotatedData, 'padding');
    [ModelTable, ~, g] = unique(AnnotatedData(:,{'unit_id','unit_category','unit_contribution'}));
    ModelTable.lme = cell(size(ModelTable,1),1);
    for i = unique(g)'
        z = g == i;
        ModelTable.lme{i} = fitlme(AnnotatedData(z,:),'distorted_activation~example_category+(1|subject)');
    end
    summary = summary_table(ModelTable);
    disp(summary);
end

function d = apply_conditional_sort(d,~)
% TODO
end

function t = summary_table( ModelTable )
    ModelTable.estimate = cellfun(@(x) x.Coefficients.Estimate(2), ModelTable.lme);
    ModelTable.se = cellfun(@(x) x.Coefficients.SE(2), ModelTable.lme);
    allvars = {'unit_category','unit_contribution','estimate','se'};
    groupby = {'unit_category','unit_contribution'};
    t = grpstats(ModelTable(:,allvars),groupby);
end