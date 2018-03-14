function [d,SortInfo,nvox] = AddNoiseAndShuffle(d,sh,narb,method)
%% Setup
	nsub = size(d,1);
	nitem = size(d{1},1);
	N = nitem*nsub;
	nvox = sum(reshape(cellfun(@(x) size(x,2), d(1,:)),2,3));
    if iscell(narb)
        narbToShuffleIn = cellfun(@(x) x(end), narb);
        narb_mat = cellfun(@(x) x(1), narb);
    else
        narb_mat = narb;
        narbToShuffleIn = narb;
    end
	nArb = narb_mat .* [2,1,2];
    nArbToShuffleIn = narbToShuffleIn .* [2,1,2];
	nAll = nvox + nArb;

%% Insert the arb units
	subBins = repmat(nitem,nsub,1);
	d = [d(:,1:2),...
		mat2cell(zeros(N,nArb(1)),subBins,nArb(1)), ...
		d(:,3:4),...
		mat2cell(zeros(N,nArb(2)),subBins,nArb(2)), ...
		d(:,5:6),...
		mat2cell(zeros(N,nArb(3)),subBins,nArb(3))];

%% Index all units for sorting 
	switch method
	case 'permute'
		IJK = zeros(sum(nAll),nsub+1);
		for ii=1:3
			ix = (1:nAll(ii)) + sum(nAll(1:ii-1));
			IJK(ix,1) = ii;
			if sh(ii)
				for ss=1:nsub
					IJK(ix,ss+1)=[randperm(nvox(ii) + nArbToShuffleIn(ii)), (nvox(ii)+nArbToShuffleIn(ii)+1):nAll(ii)];
				end
            else
                for ss = 1:nsub
                    IJK(ix,ss+1) = 1:nAll(ii);
                end
			end
		end
		ix = zeros(sum(nAll),nsub);
		xi = zeros(sum(nAll),nsub);
		for ss=1:nsub
			%% Generate sort
			[~,ix(:,ss)] = sortrows(IJK(:,[1,ss+1]));
			[~,xi(:,ss)] = sort(ix(:,ss));
			%% Apply sort
			Xj = cell2mat(d(ss,:));
			Xj = Xj(:,ix(:,ss));
			d(ss,1:3) = mat2cell(Xj,nitem,nAll);
		end
		d(:,4:end) = [];

	case {'interleave','interleaved'}
		IJK = zeros(sum(nAll),3);
		n = nvox ./ [4,2,4];
		blkstr = {[0,1,0,1],[0,0],[0,1,0,1]};
		for ii=1:3
			if sh(ii)
				ix1 = (1:nvox(ii)) + sum(nvox(1:ii-1));
				ix2 = (ix1(end)+1):(ix1(end)+nArb(ii)); 
				m = length(blkstr{ii});
				[i,j,k] = ndgrid(ii,[1:n(ii)],blkstr{ii});
				IJK(ix1,:)=[i(:),j(:),k(:)];
				[i,j,k] = ndgrid(ii,mod(0:narb(ii)-1,n(ii))+1,blkstr{ii}(1:m/2));
				IJK(ix2,:)=[i(:),j(:),k(:)];
			else
				ix = (1:nAll(ii)) + sum(nAll(1:ii-1));
				IJK(ix,1) = ii;
				IJK(ix,2) = 1:nAll(ii);
			end
		end
		%% Generate sort
		[~,ix] = sortrows(IJK);
		[~,xi] = sort(ix);
		%% Apply sort
		X = cell2mat(d);
		X = X(:,ix);
		d = mat2cell(X,repmat(nitem,nsub,1),nAll);
        
	case 'blocked_interleave'
		IJK = zeros(sum(nAll),3);
		n = nvox ./ [4,2,4];
		blkstr = {[0,1,0,1],[0,0],[0,1,0,1]};
        for ii=1:3
			if sh(ii)
				ix1 = (1:nvox(ii)) + sum(nvox(1:ii-1));
				ix2 = (ix1(end)+1):(ix1(end)+nArb(ii)); 
				m = length(blkstr{ii});
				[i,j,k] = ndgrid(ii,[1:n(ii)],blkstr{ii});
				IJK(ix1,:)=[i(:),j(:),k(:)];
				[i,j,k] = ndgrid(ii,mod(0:narb(ii)-1,n(ii))+1,blkstr{ii}(1:m/2));
				IJK(ix2,:)=[i(:),j(:),k(:)];
			else
				ix = (1:nAll(ii)) + sum(nAll(1:ii-1));
				IJK(ix,1) = ii;
				IJK(ix,2) = ix;
			end
        end
        % This is the new bit for blocked interleaving
        IJK(ix1(1:7),3) = 2; % systematic hidden
        IJK(ix1(8:14),3) = 3; % idiosyncratic hidden
        a = (nArb(2)-floor(nArb(2)/4));
        b = a+1;
%         IJK(ix2(1:a),3) = 1;   % arbitrary, first 3/4
%         IJK(ix2(b:end),3) = 4; % arbitrary, last 1/4
        IJK(ix2,3) = 1;

        tmp = IJK(ix1,2);
        ind = tmp;
        tmp(ismember(ind,[1,2])) = 1;
        tmp(ismember(ind,[3,4,5])) = 2;
        tmp(ismember(ind,[6,7])) = 3;
        IJK(ix1,2) = tmp;
        IJK(ix2,2) = reshape(repmat(1:4,7,1),28,1);
		%% Generate sort
		[IJKcheck,ix] = sortrows(IJK);
		[~,xi] = sort(ix);
		%% Apply sort
		X = cell2mat(d);
		X = X(:,ix);
		d = mat2cell(X,repmat(nitem,nsub,1),nAll);
        
case 'blocked_permute'
		IJK = zeros(sum(nAll),3);
		n = nvox ./ [4,2,4];
		blkstr = {[0,1,0,1],[0,0],[0,1,0,1]};
        for ii=1:3
			if sh(ii)
				ix1 = (1:nvox(ii)) + sum(nvox(1:ii-1));
				ix2 = (ix1(end)+1):(ix1(end)+nArb(ii)); 
				m = length(blkstr{ii});
				[i,j,k] = ndgrid(ii,[1:n(ii)],blkstr{ii});
				IJK(ix1,:)=[i(:),j(:),k(:)];
				[i,j,k] = ndgrid(ii,mod(0:narb(ii)-1,n(ii))+1,blkstr{ii}(1:m/2));
				IJK(ix2,:)=[i(:),j(:),k(:)];
			else
				ix = (1:nAll(ii)) + sum(nAll(1:ii-1));
				IJK(ix,1) = ii;
				IJK(ix,2) = ix;
			end
        end
        % This is the new bit for blocked interleaving
        IJK(ix1(1:7),3) = 2; % systematic hidden
        IJK(ix1(8:14),3) = 3; % idiosyncratic hidden
        a = (nArb(2)-floor(nArb(2)/3));
        b = a+1;
%         IJK(ix2(1:a),3) = 1;   % arbitrary, first 3/4
%         IJK(ix2(b:end),3) = 4; % arbitrary, last 1/4
        IJK(ix2,3) = 1;

        tmp = IJK(ix1,2);
        ind = tmp;
        tmp(ismember(ind,[1,2])) = 1;
        tmp(ismember(ind,[3,4,5])) = 2;
        tmp(ismember(ind,[6,7])) = 3;
        IJK(ix1,2) = tmp;
        IJK(ix2,2) = [reshape(repmat(1:3,9,1),27,1);4];
        IJK_step1_prep = IJK;
		%% Generate sort
		[IJK_step1,ix_step1] = sortrows(IJK_step1_prep);
        IJK_step2_prep = IJK_step1;
        FullIndex = 1:114;
        FullIndex_step1 = FullIndex(ix_step1);
        ix = zeros(sum(nAll),nsub);
        for ss = 1:10
            for j = 1:3
                z = IJK_step1(:,2) == j;
                n = nnz(IJK_step1(z,3) == 2) * 3;
                m = nnz(z);
                IJK_step2_prep(z,3) = zeros(m,1);
                z(z) = [false(m-n,1);true(n,1)];
                IJK_step2_prep(z,3) = randperm(n);
            end
            [IJK_step2,ix_step2] = sortrows(IJK_step2_prep);
            FullIndex_step2 = FullIndex_step1(ix_step2);
            ix(:,ss) = FullIndex_step2;
            Xj = cell2mat(d(ss,:));
			Xj = Xj(:,ix(:,ss));
			d(ss,1:3) = mat2cell(Xj,nitem,nAll);
        end
		[~,xi] = sort(ix);
		d(:,4:end) = [];
        check_block_permute(ix,IJK_step1_prep,IJK_step1,IJK_step2_prep,IJK_step2)
        
	case 'local'
		ix=1:sum(nAll);
		xi=ix;
        % MERGE Groups within layers
        INN = cell(nsub, 1);
        HID = cell(nsub, 1);
        OUT = cell(nsub, 1);
        for i = 1:nsub
            INN{i} = cell2mat(d(i,1:3));
            HID{i} = cell2mat(d(i,4:6));
            OUT{i} = cell2mat(d(i,7:9));
        end
        d = [INN, HID, OUT];
    end

	SortInfo.nAll = nAll;
	SortInfo.nvox = nvox;
	SortInfo.nArb = nArb;
	SortInfo.shuffle = ix;
	SortInfo.unwravel = xi;
	nvox = length(ix);
    
end

function check_block_permute(ix,IJK_step1_prep,IJK_step1,IJK_step2_prep,IJK_step2)
    subplot(3,2,1), imagesc(IJK_step1_prep(IJK_step1_prep(:,1)==2,2:3)); title('Step 1 Prep');
    subplot(3,2,2), imagesc(IJK_step1(IJK_step1(:,1)==2,2:3));  title('Step 1');
    subplot(3,2,3), imagesc(IJK_step2_prep(IJK_step2_prep(:,1)==2,2:3));  title('Step 2 Prep');
    subplot(3,2,4), imagesc(IJK_step2(IJK_step2(:,1)==2,2:3));  title('Step 2');

    ijkhidden = IJK_step1_prep(IJK_step1_prep(:,1)==2,:);
    ixhidden = ix(IJK_step1_prep(:,1)==2,end) - 36;
    subplot(3,2,5), imagesc(ijkhidden(ixhidden,2:3));  title('Two steps in one');

    ixhidden = ix(IJK_step1_prep(:,1)==2,:) - 36;
    tmp = zeros(size(ixhidden));
    for i = 1:size(tmp, 2), tmp(:,i) = ijkhidden(ixhidden(:,i),3); end
    subplot(3,2,6), imagesc(tmp);  title('All hidden layer permutations');
    hold on
    line([0,10.5],[13,13]+1,'Color','red','LineWidth',2);
    line([0,10.5],[13+15,13+15]+1,'Color','red','LineWidth',2);
end