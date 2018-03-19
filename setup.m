% SETUP Construct annotated table of simulation data
%
% Suppress Warnings about repmat(0,...) and repmat(1,...). It is a
% deliberate choice to maintain consistent syntax.
%#ok<*RPMT0,*RPMT1> 

%% Annotate simulation data
% ==========
% 'raw/9c2_all.txt' contains the activation patterns over a neural network
% for 72 examples (36 category A, 36 category B). Each row is the
% activation pattern over thw whole network for a single example for a
% single "subject" (i.e., model state originating from a unique random
% configuration of weights). Rows are blocked by subject. Columns are
% ordered as follows:
%
% 18 Systematic Input units   'SI' ( 1:18)
% 18 Arbitrary Input units    'AI' (19:36)
%  7 Systematic Hidden units  'SH' (37:43)
%  7 Arbitrary Hidden units   'AH' (44:50)
% 18 Systematic Output units  'SO' (51:68)
% 18 Arbitrary Output units   'AO' (69:86)
%
% N.B. The first column is the example ID and the second is (supposed to
% be) the subject ID. So, those column ranges above are only accurate after
% dropping the first 2 columns.

tmp = dlmread('raw/9c2_all.txt');
% Fastest changing index is k
[k,j,i] = ndgrid(1:86,1:72,1:10);
% First 36 are examples of category A items.
ct = categorical(j(:)>36, 0:1, {'A','B'});
% Tag each unit with a category label
gr = repmat([
    repmat(1,18,1)
    repmat(2,18,1)
    repmat(3, 7,1)
    repmat(4, 7,1)
    repmat(5,18,1)
    repmat(6,18,1)
    ], 10*72, 1);
gr = categorical(gr, 1:8, {'SI','AI','SH','AH','SO','AO','noise','padding'},'Ordinal',true);
% unit_id_by_category
gu = repmat([
    (1:18)'
    (1:18)'
    (1:7)'
    (1:7)'
    (1:18)'
    (1:18)'
    ], 10*72, 1);
gu = categorical(gu);
% unit_contribution (does it encode information about A, B, both, or
% neither?)
uc = repmat([
    repmat(1, 9,1)
    repmat(2, 9,1)
    repmat(0,18,1)
    repmat(3, 7,1)
    repmat(0, 7,1)
    repmat(1, 9,1)
    repmat(2, 9,1)
    repmat(0,18,1)
    ], 10*72, 1);
uc = categorical(uc, 0:3, {'neither','A','B','both'});
% Reshape the activation matrix into a vector
aa = reshape(tmp(:,3:end)',numel(i),1);
% Subject ID
ss = categorical(i(:));
% Example ID
ee = categorical(j(:));
% Unit ID
uu = categorical(k(:));
% Assemble table from these pieces
AnnotatedData = table(ss,ct,ee,gr,uu,gu,uc,aa, ...
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
clear ss ct ee gr uu gu uc aa i j k tmp

%% Add Noise and Padding (to isolate regions)
% ==========
% Add noise units to increase chance of false alarms/make true signal more
% sparse. This must be the first modification made to the dataset. Units
% are simply appended to each example's/subject's representation, so after
% running this function the highest unit_ids will be associated with noise
% units.
MaximumNoiseUnits = 28; % units
AnnotatedData = AddNoiseUnits(AnnotatedData, MaximumNoiseUnits);

% Add units for padding. For important explanations of how this works and
% fits into the general setup:
%   help('AddPaddingUnits')
GroupsToIsolate = {{'SI','AI'},{'SH','AH','noise'},{'SO','AO'}};
MaximumGapSize = 28; % units
AnnotatedData = AddPaddingUnits(AnnotatedData, GroupsToIsolate, MaximumGapSize);

%% Distort signal
NoiseFunc = @(n) (randn(n,1) * 1) + 0;
UnitsToDistort = {'SI','AI','SH','AH','SO','AO','noise','padding'};
AnnotatedData = DistortSignal(AnnotatedData, UnitsToDistort, NoiseFunc);

%% Generate Conditions and Coordinates
% ==========
% The coordinate values assigned to each
% Sort indexes are generated with respect to only the units being permuted,
% and not the absolute index in the vector. Because noise units will be
% permuted with SH and AH units, it needs to occur after adding noise.
ConditionIndex = GenerateConditionIndex(AnnotatedData);
[coords, data, filters] = GenerateCoordinates(AnnotatedData,ConditionIndex);

%% Write data
T = struct( ...
    'label', 'AB', ...
    'type', 'category', ...
    'sim_source', [], ...
    'sim_metric', [], ...
    'target', [true(36,1);false(36,1)]);
cv = cvpartition(T.target,'kfold', 6);
cvind = max(cell2mat(arrayfun(@(i) test(cv,i) * i, 1:6, 'UniformOutput', 0)),[],2);
metadata = struct( ...
    'subject', num2cell(1:10), ...
    'targets', T, ...
    'cvind', {cvind}, ...
    'coords', mat2cell(reshape(rmfield(coords,'subject'),10,5),ones(10,1),5)', ...
    'filters', num2cell(rmfield(filters,'subject')), ...
    'nrow', size(data(1).X,1), ...
    'ncol', size(data(1).X,2));

for i = 1:10
    f = fullfile('data',sprintf('s%02d.mat', i));
    X = data(i).X;
    save(f, 'X');
end
save(fullfile('data','metadata.mat'), 'metadata');
save(fullfile('data','AnnotatedData.mat'), 'AnnotatedData');
save(fullfile('data','ConditionIndex.mat'), 'ConditionIndex');
