function [ t ] = ChooseBestConfig( tunedir, analysis )
%CHOOSEBESTCONFIG Wrapper to BestCfgByCondition with expected values by 
%   Detailed explanation goes hereBestCfgByCondition
    switch analysis
        case 'lasso'
            t = BestCfgByCondition(tunedir, 'lasso', ...
                {'lamL1'}, ... % hyperparams
                'err1', ...    % objective
                {'nzvox'}, ... % extras
                {'condition','subject'}); % group by

        case 'ridge'
            t = BestCfgByCondition(tunedir, 'ridge', ...
                {'lamL2'}, ... % hyperparams
                'err1', ...    % objective
                {'nzvox'}, ... % extras
                {'condition','subject'}); % group by
            
        case 'soslasso'
            t = BestCfgByCondition(tunedir, 'soslasso', ...
                {'lamSOS','lamL1','diameter'}, ... % hyperparams
                'err1', ...                        % objective
                {'nzvox'}, ...                     % extras
                {'condition'});                    % group by
    end
end

