function ix = generateLocal(N)
    n = sum([N.SH,N.AH,N.noise]);
    ix = repmat((1:n)',1,N.subjects);
end
