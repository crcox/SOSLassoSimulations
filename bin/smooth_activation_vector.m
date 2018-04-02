function x = smooth_activation_vector(d, varargin)
    p = inputParser();
    addRequired(p,'d',@istable);
    addParameter(p,'method','exponential',@(x) any(strcmpi(x,{'exponential','gaussian','boxcar'})));
    addParameter(p,'neighbors',1,@(x) isscalar(x) && x>0);
    parse(p, d, varargin{:});
    splitapply_local = defineIfNotBuiltin('splitapply',@splitapply_crc);
    [~,~,g] = unique(d(:,{'subject','example_id'}));
    switch lower(p.Results.method)
        case 'exponential'
            blurfunc = @(x) {exponential_blur(x,1)};
        case 'gaussian'
            blurfunc = @(x) {gaussian_blur(x,1)};
        case 'boxcar'
            blurfunc = @(x) {boxcar_blur(x,1)};
    end
    smooth_activation = splitapply_local(blurfunc,d.distorted_activation,g);
    x = cell2mat(smooth_activation);
end
