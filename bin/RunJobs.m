function RunJobs( varargin )
%RUNJOBS Run analyses defined in subdirectories of basedir
%  WholeBrain_MVPA and Searchlight_MVPA are designed to accomodate
%  distributed high-throughput computing, and so are most convientiently
%  used in the context of parameter files spread across multiple folders.
%  If you have access to a compute cluster, you may prefer to leverage
%  those resources to do parameter tuning. But, for fitting a small number
%  of models, a single work station will suffice.
%
%  If RunJobs is run within a directory containing a set of numbered
%  sub-directories that contain configuration files (or is pointed to such
%  a directory using the optional 'basedir' argument, it will run the jobs
%  that you specify. If joblist = [1], it will run the configuration in
%  folder 'basedir/0' (or 'basedir/00', or 'basedir/000', etc). That is to
%  say, although the folder names will be zero-based and zero
%  padded, the joblist should be one-based numeric data.
%
%  If joblist is empty, HTCondorListJobDirs() will be called on the basedir
%  (which, if not explicitly specified, is the current directory).
%
%  RunJobs will check the path to the basedir to determine whether
%  WholeBrain_MVPA or Searchlight_MVPA should be run.
%
%  By default, RunJobs will skip directories that already have a
%  'results.mat' file. To regenerate all results for jobs in the joblist,
%  use the key-value pair 'overwrite', true.
    r = pwd();
    p = inputParser();
    addOptional(p,'joblist',[],@(x) isnumeric(x) && all(x>0));
    addOptional(p,'basedir',r,@ischar);
    addParameter(p,'overwrite',false,@islogical);
    parse(p, varargin{:});
    
    basedir = GetFullPath(p.Results.basedir);
    if ~exist(basedir,'dir')
        error('There does not seem to be a directory at %s ...', basedir);
    end
    if check_analysis_type(basedir, 'searchlight')
        MVPA = @Searchlight_MVPA;
    else
        MVPA = @WholeBrain_MVPA;
    end
    
    if isempty(p.Results.joblist)
        joblist_str = HTCondorListJobDirs(basedir);
        joblist_abspath = fullfile(basedir, joblist_str);
    else
        n = count_digits_int(max(joblist)-1);
        fmt = sprintf('%%0%dd',n);
        joblist_str = arrayfun(@(i) sprintf(fmt, i), p.Results.joblist - 1, 'UniformOutput', false);
        joblist_abspath = fullfile(basedir,joblist_str);
    end
    
    for i = 1:numel(joblist_abspath)
        d = joblist_abspath{i};
        cd(d);
        try
            if exist('results.mat','file')
                if p.Results.overwrite
                    MVPA();
                end
            else
                MVPA();
            end
        catch ME
            cd(r);
            rethrow(ME);
        end
        cd(r);
    end
end

function n = count_digits_int(x)
    n = 0;
    if x == 0
        n = 1;
        return
    end
    while x >= 1
        n = n + 1;
        x = x / 10;
    end
end

function t = check_analysis_type( rpath, varargin )
    p = inputParser();
    addRequired(p,'rpath');
    addOptional(p,'istype',[],@ischar);
    parse(p, rpath, varargin{:});
    
    parts = strsplit(rpath,filesep());
    ix = find(strcmp('results',parts));
    analysis_type = parts{ix+1};
    if isempty(p.Results.istype)
        t = analysis_type;
    else
        t = strcmp(analysis_type, p.Results.istype);
    end
end