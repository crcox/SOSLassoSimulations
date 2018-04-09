function [ ModelTable, WeightTable, summary ] = GLMNetAnalysis( AnnotatedData, metadata  )
%GLMNETANALYSIS Run LASSO with GLMnet, which is much faster and more
% efficient than WholeBrain MVPA but implements a simpler optimization.
    cvind = metadata(1).cvind;
    AnnotatedData = DistortSignal(AnnotatedData, 1.0);
    AnnotatedData = drop_rows_by_unit_category(AnnotatedData, {'padding'});
    [ModelTable, ~, g] = unique(AnnotatedData(:,{'subject'}));
    WeightTable = unique(AnnotatedData(:,{'subject','unit_id','unit_category','unit_contribution'}));
    WeightTable.weights = zeros(size(WeightTable, 1), 1);
    ModelTable.glmnet = cell(size(ModelTable,1),1);
    for i = unique(g)'
        z = g == i;
        d = AnnotatedData(z,{'subject','example_id','distorted_activation','example_category','unit_id'});
        [X,y] = reformat_data(d);
        X = zscore(X);
        opts = glmnetSet(struct('intr',0));
        cvfit = cvglmnet(X,y,'binomial',opts,'deviance',6,cvind,false);
        opts.lambda = cvfit.lambda_min;
        ModelTable.glmnet{i} = glmnet(X,y,'binomial',opts);
        z = WeightTable.subject == num2str(i);
        WeightTable.weights(z) = ModelTable.glmnet{i}.beta;
    end
    summary = summary_table(WeightTable);
    disp(summary);
end

function [X,y,regs] = reformat_data(d)
    dw = unstack(d,'distorted_activation','unit_id');
    uid = str2double(cellstr(unique(d.unit_id)));
    regs = arrayfun(@(x) sprintf('x%d', x), uid, 'UniformOutput', false);
    X = table2array(dw(:,regs));
    y = (dw.example_category == 'B')+0;
end

function t = summary_table(WeightTable)
    WeightTable.abs_weights = abs(WeightTable.weights);
    WeightTable.nz_weights = WeightTable.weights ~= 0;
    allvars = {'unit_category','unit_contribution','abs_weights','nz_weights'};
    groupby = {'unit_category','unit_contribution'};
    t = grpstats(WeightTable(:,allvars),groupby);
end
