function [] = MakeSensitivityFigure(TPFP)
    TPFP.d = (TPFP.tp ./ TPFP.np) - (TPFP.fp ./ TPFP.nn);
    z = ismember(TPFP.condition, {'blocked permuted balanced', 'local'});
    TPFP = TPFP(z,{'condition','layer','d'});
    bar(reshape(TPFP.d,2,2));
    a = gca();
    a.XTickLabel = cellstr(TPFP.layer([1,2]));
    ylim([-0.1,1.1])
    legend(cellstr(TPFP.condition([1,3])));
end