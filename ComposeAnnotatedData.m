function [AnnotatedData] = ComposeAnnotatedData(raw)
%COMPOSEANNOTATEDDATA Prepare model activation data for analysis
%   This function accepts no options, only the data table as read from 
%
% Suppress Warnings about repmat(0,...) and repmat(1,...). It is a
% deliberate choice to maintain consistent syntax.
%#ok<*RPMT0,*RPMT1> 
    % Fastest changing index is k
    nunits = 86; nitems = 72; nsubj = 10;
    [k,j,i] = ndgrid(1:nunits,1:nitems,1:nsubj);
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
    % unit_contribution
    % ++ Does the unit encode information about A, B, both, or neither?
    % N.B. Indexing begins at zero.
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
    % Extract activation matrix
    % N.B. First 3 columns of data table are metadata (subject, unitID, type)
    % N.B. unit-by-item/subj (after transposition)
    A = table2array(raw(:,4:end))';
    % Reshape the activation matrix into a vector
    aa = A(:);
    % Subject ID
    ss = i(:);
    % Example ID
    ee = j(:);
    % Unit ID
    uu = k(:);
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
end

