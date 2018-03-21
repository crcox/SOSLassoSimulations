% RUNALL
%
addpath('C:\Users\mbmhscc4\MATLAB\src\WholeBrain_MVPA\src');
addpath('C:\Users\mbmhscc4\MATLAB\src\WholeBrain_MVPA\dependencies\jsonlab\');
r = pwd();
for i = 1:250
    d = sprintf('%03d', i-1);
    cd(d);
    try
        if ~exist('results.mat','file')
            WholeBrain_MVPA();
        end
    catch ME
        cd(r);
        rethrow(ME);
    end
    cd(r);
end
    
    