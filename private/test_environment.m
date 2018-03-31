N = struct('subjects',1,'SH',7,'AH',7,'noise',28);
n = N.SH+N.AH+N.noise;
subject = reshape(repmat(1:N.subjects,n,1),[],1);
unit_id = repmat((1:n)',N.subjects,1);
unit_id_by_category = repmat([1:N.SH,1:N.AH,1:N.noise]',N.subjects,1);
unit_category = repmat([ones(N.SH,1);ones(N.AH,1)*2;ones(N.noise,1)*3],N.subjects,1);
unit_contribution = repmat([ones(N.SH,1);ones(N.AH+N.noise,1)*2],N.subjects,1);
D = table( ...
    ordinal(subject,[],1:N.subjects), ...
    categorical(unit_category,1:3,{'SH','AH','noise'}), ...
    ordinal(unit_id,[],1:n), ...
    ordinal(unit_id_by_category,[],1:max([N.SH,N.AH,N.noise])), ...
    categorical(unit_contribution,1:2,{'both','neither'}), ...
    'VariableName', {
        'subject'
        'unit_category'
        'unit_id'
        'unit_id_by_category'
        'unit_contribution'
    });
[ix, tmp] = generateBlockedPermuted(N);
D(ix,:)