% RUNALL
%
addpath('C:\Users\chriscox\Documents\GitHub\WISC_MVPA\src');
addpath('C:\Users\chriscox\Documents\GitHub\WISC_MVPA\dependencies\jsonlab\');
r = pwd();
for i = 1:250
    d = sprintf('%03d', i-1);
    cd(d);
    try
        if ~exist('results.mat','file')
            WISC_MVPA();
        end
    catch ME
        cd(r);
        rethrow(ME);
    end
    cd(r);
end
    
    