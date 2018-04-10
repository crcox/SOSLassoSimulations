function [ix,tmp] = generateSplitPermuted(N)
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

    r = rem(N.SH,uint8(3));
    d = idivide(N.SH,uint8(3));
    x = repmat(d,3,1);
    x(1:r) = x(1:r)+1;
    a = ones(3, 3);
    b = cumsum(unique(perms(x),'rows'));
    a(2:3,:) = b(1:2,:) + 1;
    for i = 1:numel(UC)
        uc = UC{i};
        z = tmp.unit_category==uc;
        tmp1 = zeros(nnz(z), 1);
        for j = 1:3 % blocks
            tmp1(a(j,i):b(j,i)) = j;
        end
        tmp.tmp1(z) = tmp1;
    end
    tmp.tmp2 = zeros(size(tmp,1),1);
    tmp.tmp2(tmp.tmp1>0) = 1;
    tmp.tmp1(tmp.tmp1==0) = 4;

    % Generate different permutation for each subject, within
    % blocked constraints
    n = sum([N.SH,N.AH,N.noise]);
    ix = zeros(n, N.subjects);
    for j = 1:N.subjects
        for i = 1:3
            z = tmp.tmp1 == i & tmp.tmp2 == 1;
            n = nnz(z);
            tmp.tmp3(z) = randperm(n);
        end
        [~,ix(:,j)] = sortrows(tmp, {'tmp1','tmp3'});
    end
end
