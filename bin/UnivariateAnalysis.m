function [ ModelTable, summary ] = UnivariateAnalysis( AnnotatedData, ConditionIndex )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    conditions = categories(ConditionIndex.condition);
    AnnotatedData = DistortSignal(AnnotatedData, 1.0);
    AnnotatedData.example_category_code = (AnnotatedData.example_category == 'B') + 0;
    MM = cell(numel(conditions), 1);
    for j = 1:numel(conditions)
        D = apply_conditional_sort(AnnotatedData, ConditionIndex, conditions{j});
        D.activation = smooth_activation_vector(D);
        D = drop_rows_by_unit_category(D, 'padding');
        [M, ~, g] = unique(D(:,{'unit_id','unit_category','unit_contribution'}));
        M.lme = cell(size(M,1),1);
        M.condition = repmat(conditions(j),size(M,1),1);
        for i = unique(g)'
            z = g == i;
            M.lme{i} = fitlme(AnnotatedData(z,{'distorted_activation','example_category_code','subject'}),'distorted_activation~example_category_code+(1|subject)');
        end
        MM{j} = M;
    end
    ModelTable = cat(1, MM{:});
    ModelTable.condition = categorical(ModelTable.condition);
    summary = summary_table(ModelTable);
    disp(summary);
end

function d = apply_conditional_sort(d,ci,cond)
    z = ci.condition == cond;
    ci = ci(z,{'subject','unit_id','index'});
    d = outerjoin(d,ci,'Keys',{'subject','unit_id'},'MergeKeys',true);
    z = isnan(d.index);
    d.index(z) = d.padded_unit_id(z);
    d = sortrows(d,{'subject','example_id','padded_blocks','index'});
end

function t = summary_table( ModelTable )
    ModelTable.estimate = cellfun(@(x) x.Coefficients.Estimate(2), ModelTable.lme);
    ModelTable.se = cellfun(@(x) x.Coefficients.SE(2), ModelTable.lme);
    allvars = {'condition','unit_category','unit_contribution','estimate','se'};
    groupby = {'condition','unit_category','unit_contribution'};
    t = grpstats(ModelTable(:,allvars),groupby);
end