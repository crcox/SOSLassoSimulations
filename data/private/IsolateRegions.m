function [d,p] = IsolateRegions(d,sz)
	nitem = size(d{1},1);
	nsub = size(d,1);
	d = cellfun(@(x) [ones(nitem,sz),x,ones(nitem,sz)], d, 'unif',0);
	X = cell2mat(d);
	p = all(X==1);
	X(:,p) = 0;
	nvox = size(X,2);
	d = mat2cell(X,repmat(nitem,nsub,1),nvox);
end
