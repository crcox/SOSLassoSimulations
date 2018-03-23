function x = soslasso_penalty(w, lamSOS, lamL1, gsize, overlap)
    n = size(w,2);
    g = compose_groups(n, gsize, overlap);
    x = zeros(1,numel(g));
    for i = 1:numel(g)
        v = reshape(w(:,g{i}),[],1);
        x(i) = (lamL1 * norm(v,1)) + (lamSOS * norm(v,2));
    end
end

function g = compose_groups(n, size,overlap)
    shift = size - overlap;
    b = 0;
    g = cell(n,1);
    i = 0;
    while b < n
        i = i + 1;
        a = b + 1;
        b = b + shift;
        g{i} = a:(a+size-1);
    end
    z = cellfun('isempty',g);
    g = g(~z);
    for i = 1:numel(g)
        g{i}(g{i}>n) = [];
    end 
end