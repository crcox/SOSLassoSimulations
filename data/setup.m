% Setup annotated table of simulation activation values
% ==========
% 'raw/9c2_all.txt' contains the activation patterns over a neural network
% for 72 examples (36 category A, 36 category B).
tmp = dlmread('raw/9c2_all.txt');
[k,j,i] = ndgrid(1:86,1:72,1:10);
ct = categorical(j(:)>36, 0:1, {'A','B'});
gr = repmat([
    repmat(1,18,1)
    repmat(2,18,1)
    repmat(3, 7,1)
    repmat(4, 7,1)
    repmat(5,18,1)
    repmat(6,18,1)
    ], 10*72, 1); %#ok<REPMAT>
gr = categorical(gr, 1:8, {'SI','AI','SH','AH','SO','AO','noise','padding'},'Ordinal',true);
gu = repmat([
    (1:18)'
    (1:18)'
    (1:7)'
    (1:7)'
    (1:18)'
    (1:18)'
    ], 10*72, 1);
uc = repmat([
    repmat(1, 9,1)
    repmat(2, 9,1)
    repmat(0,18,1)
    repmat(3, 7,1)
    repmat(0, 7,1)
    repmat(1, 9,1)
    repmat(2, 9,1)
    repmat(0,18,1)
    ], 10*72, 1); %#ok<REPMAT>
gu = categorical(gu);
uc = categorical(uc, 0:3, {'neither','A','B','both'});
aa = reshape(tmp(:,3:end)',numel(i),1);

% Coordinates
% The coordinate values assigned to each
ss = categorical(i(:));
ee = categorical(j(:));
uu = categorical(k(:));
d = table(ss,ct,ee,gr,uu,gu,uc,aa, ...
    'VariableNames',{
        'subject'
        'example_category'
        'example_id'
        'unit_category'
        'unit_id'
        'unit_id_by_category'
        'unit_contribution'
        'activation'
    });

% Note, it is important to add noise first, and then add padding.
% Add noise units to increase chance of false alarms/make true signal more
% sparse
MaximumNoiseUnits = 28; % units
d = AddNoiseUnits(d, MaximumNoiseUnits);

% Add units for padding
GroupsToIsolate = {{'SI','AI'},{'SH','AH'},{'SO','AO'},{'noise'}};
MaximumGapSize = 28; % units
d = AddPaddingUnits(d, GroupsToIsolate, MaximumGapSize);

% Sort the noise and padding to integrate with each subject and example.
d = sortrows(d,1:7);

% Shuffle and Dilute
GroupsToShuffle = {'SH','AH'};
DiluteInfo = struct('nunits', 28, 'value', 0);
ShuffleMethod = 'blocked_permute';
