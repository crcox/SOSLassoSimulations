function [ix,tmp] = generateBlockedInterleaved(N)
    tmp = table( ...
        categorical(...
            [repmat(1, N.SH, 1); ...
            repmat(2, N.AH, 1); ...
            repmat(3, N.noise, 1)], 1:3, {'SH','AH','noise'}), ...
        [1:N.SH,1:N.AH,1:N.noise]', ...
        'VariableNames', {'unit_category','unit_id_by_category'}); %#ok<RPMT1>
    UC = {'SH','AH','noise'};
    tmp.tmp = zeros(size(tmp,1),1);
    for i = 1:numel(UC)
        uc = UC{i};
        z = tmp.unit_category==uc;
        x = tmp.unit_id_by_category(z);
        if strcmp(uc, 'noise')
            tmp.tmp(z) = mod(x - 1, 4);
        else
            tmp.tmp(z) = mod(x - 1, 3) + 1;
        end
    end
    [~,ix] = sortrows(tmp, {'tmp','unit_category','unit_id_by_category'});
    ix = repmat(ix,1,N.subjects);
end
