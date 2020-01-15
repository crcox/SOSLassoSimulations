% SETUP Construct annotated table of simulation data
%
addpath('./bin')
DATA_OUTPUT_DIR = 'data_01';
if ~exist(DATA_OUTPUT_DIR, 'dir')
    mkdir(DATA_OUTPUT_DIR);
end
%% Annotate simulation data
% ==========
% 'raw/simulation_fMRI_nonoise.csv' contains the activation patterns over a
% neural network for 72 examples (36 category A, 36 category B). Each row
% is the activation pattern over the whole network for a single example for
% a single "subject" (i.e., model state originating from a unique random
% configuration of weights). Rows are blocked by subject. Excluding the
% first three columns (subject, unitID, type), the columns corresponding to
% units are ordered as follows:
%
% 18 Systematic Input units   'SI' ( 1:18)
% 18 Arbitrary Input units    'AI' (19:36)
%  7 Systematic Hidden units  'SH' (37:43)
%  7 Arbitrary Hidden units   'AH' (44:50)
% 18 Systematic Output units  'SO' (51:68)
% 18 Arbitrary Output units   'AO' (69:86)
%
tmp = readtable('raw/simulation_fMRI_nonoise.csv');
AnnotatedData = ComposeAnnotatedData(tmp);
clear tmp

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
NoiseFunc = @(n) (randn(n,1) .* 1) + 0;
UnitsToDistort = {'SI','AI','SH','AH','SO','AO','noise','padding'};
AnnotatedData = AddNoiseChannel(AnnotatedData, UnitsToDistort, NoiseFunc);

%% Generate Conditions and Coordinates
% ==========
% The coordinate values assigned to each
% Sort indexes are generated with respect to only the units being permuted,
% and not the absolute index in the vector. Because noise units will be
% permuted with SH and AH units, it needs to occur after adding noise.
ConditionIndex = GenerateConditionIndex(AnnotatedData);

save(fullfile(DATA_OUTPUT_DIR,'AnnotatedData.mat'), 'AnnotatedData');
save(fullfile(DATA_OUTPUT_DIR,'ConditionIndex.mat'), 'ConditionIndex');

strength_list = 0.4:0.2:1.0;
for j = 1:numel(strength_list)
    strength = strength_list(j);
    [coords, data, filters] = GenerateCoordinates( ...
        AnnotatedData, ...
        ConditionIndex, ...
        'NoiseStrength',strength);

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
        'coords', mat2cell(reshape(rmfield(coords,'subject'),10,6),ones(10,1),6)', ...
        'filters', num2cell(rmfield(filters,'subject')), ...
        'nrow', size(data(1).X,1), ...
        'ncol', size(data(1).X,2));

    for i = 1:10
        f = fullfile(DATA_OUTPUT_DIR,sprintf('s%02d_noise%03d.mat', i, floor(strength*100)));
        X = data(i).X;
        save(f, 'X');
    end
    save(fullfile(DATA_OUTPUT_DIR,'metadata.mat'), 'metadata');
end