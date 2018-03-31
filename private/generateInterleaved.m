function ix = generateInterleaved(N)
    unit_id_by_category = [1:N.SH,1:N.AH,1:N.noise];
    [~,ix] = sort(mod(unit_id_by_category - 1, N.SH));
    ix = repmat(ix,1,N.subjects);
end
