function ix = generatePermuted(N)
    n = sum([N.SH,N.AH,N.noise]);
    ix = zeros(n, N.subjects);
    for ss=1:N.subjects
        ix(:,ss) = randperm(n);
    end
end
