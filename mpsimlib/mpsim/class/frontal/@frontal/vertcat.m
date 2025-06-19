function answer = vertcat (varargin)
    varargin = cellfun(@defrontal, varargin, ...
        'UniformOutput',false);
    answer = frontal(vertcat(varargin{:}));
end

