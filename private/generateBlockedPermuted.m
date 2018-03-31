function [ix,tmp] = generateBlockedPermuted(N)
    tmp = table( ...
        categorical(...
            [repmat(1, N.SH, 1); ...
            repmat(2, N.AH, 1); ...
            repmat(3, N.noise, 1)], 1:3, {'SH','AH','noise'}), ...
        [1:N.SH,1:N.AH,1:N.noise]', ...
        'VariableNames', {'unit_category','unit_id_by_category'}); %#ok<RPMT1>

    UC = {'SH','AH','noise'};
    tmp.tmp1 = zeros(size(tmp,1),1);
    tmp.tmp2 = zeros(size(tmp,1),1);
    tmp.tmp3 = zeros(size(tmp,1),1);
    for i = 1:numel(UC)
        uc = UC{i};
        z = tmp.unit_category==uc;
        x = tmp.unit_id_by_category(z);
        tmp.tmp1(z) = mod(x - 1, 3);
    end
    for j = 0:2
        n = nnz(tmp.unit_category=='SH' & tmp.tmp1 == j);
        for i = 1:numel(UC)
            uc = UC{i};
            z = tmp.unit_category==uc & tmp.tmp1 == j;
            z(z) = [true(n,1); false(nnz(z)-n,1)];
            tmp.tmp2(z) = 1;
        end
    end
    % Generate different permutation for each subject, within
    % blocked constraints
    n = sum([N.SH,N.AH,N.noise]);
    ix = zeros(n, N.subjects);
    for j = 1:N.subjects
        for i = 0:2
            z = tmp.tmp1 == i & tmp.tmp2 == 1;
            n = nnz(z);
            tmp.tmp3(z) = randperm(n);
        end
        [~,ix(:,j)] = sortrows(tmp, {'tmp1','tmp3'});
    end
end
