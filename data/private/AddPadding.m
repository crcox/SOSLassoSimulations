function [d,p] = AddPadding(d,groups,sz)
    n = 1:numel(groups);
    subjects = unique(d.subject);
    examples = unique(d.example_id);
    for i = 1:n
        G = groups{i};
        z2 = ismember(d.unit_category, G);
        for j = 1:numel(subjects)
            z1 = z2 & d.subject == subjects(j);
            for k = 1:numel(examples)
                z = z1 & d.example_id == examples(k);
                d
        
        
	nitem = size(d{1},1);
	nsub = size(d,1);
	d = cellfun(@(x) [ones(nitem,sz),x,ones(nitem,sz)], d, 'unif',0);
	X = cell2mat(d);
	p = all(X==1);
	X(:,p) = 0;
	nvox = size(X,2);
	d = mat2cell(X,repmat(nitem,nsub,1),nvox);
end
