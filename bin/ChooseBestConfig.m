function [ t ] = ChooseBestConfig( tune_dir, analysis )
%CHOOSEBESTCONFIG Wrapper to BestCfgByCondition with expected values by 
%   analysis type
    T = LoadSimulationResults( tune_dir, analysis, 'AsTable', true );
    switch analysis
        case 'lasso'
            t = BestCfgByCondition(T, ...
                {'lamL1'}, ... % hyperparams
                'err1', ...    % objective
                {'nzvox'}, ... % extras
                {'condition','subject','finalholdout'}); % group by

        case 'ridge'
            t = BestCfgByCondition(T, ...
                {'lamL2'}, ... % hyperparams
                'err1', ...    % objective
                {'nzvox'}, ... % extras
                {'condition','subject','finalholdout'}); % group by
            
        case 'soslasso'
            t = BestCfgByCondition(T, ...
                {'lamSOS','lamL1','diameter'}, ... % hyperparams
                'err1', ...                        % objective
                {'nzvox'}, ...                     % extras
                {'condition','finalholdout'});                    % group by
            
        case 'soslasso balanced'
            t = BestCfgByCondition(T, ...
                {'lamSOS','lamL1'}, ... % hyperparams
                'err1', ...                        % objective
                {'nzvox'}, ...                     % extras
                {'condition','finalholdout'});                    % group by
    end
end

