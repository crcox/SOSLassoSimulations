function [ ModelTable, summary ] = MultivariateManipulationCheck( AnnotatedData )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    AnnotatedData = DistortSignal(AnnotatedData, 1.0);
    AnnotatedData = drop_rows_by_unit_category(AnnotatedData, 'padding');
    [ModelTable, ~, g] = unique(AnnotatedData(:,{'subject','unit_category'}));
    ModelTable.glm = cell(size(ModelTable,1),1);
    for i = unique(g)'
        z = g == i;
        d = AnnotatedData(z,{'subject','example_id','distorted_activation','example_category','unit_id'});
        dw = unstack(d,'distorted_activation','unit_id');
        uid = str2double(cellstr(unique(d.unit_id)));
        n = numel(uid);
        ii = sort(randperm(n,7));
        regs = strjoin(arrayfun(@(x) sprintf('x%d', x), uid(ii), 'UniformOutput', false), '+');
        dw.y = (dw.example_category == 'B') + 0;
        ModelTable.glm{i} = fitglm(dw,sprintf('y~%s',regs),'Distribution','Binomial','Link','logit');
    end
    summary = summary_table( ModelTable );
    disp(summary);
end

function t = summary_table( ModelTable )
    ModelTable.Rsquared_Ordinary = cellfun(@(x) x.Rsquared.Ordinary, ModelTable.glm);
    ModelTable.Rsquared_Adjusted = cellfun(@(x) x.Rsquared.Adjusted, ModelTable.glm);
    ModelTable.LogLikelihood = cellfun(@(x) x.LogLikelihood, ModelTable.glm);
    ModelTable.Deviance = cellfun(@(x) x.Deviance, ModelTable.glm);
    allvars = {'unit_category','Rsquared_Ordinary','Rsquared_Adjusted','LogLikelihood','Deviance'};
    groupby = {'unit_category'};
    t = grpstats(ModelTable(:,allvars),groupby);
end