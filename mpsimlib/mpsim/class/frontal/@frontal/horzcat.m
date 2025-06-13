function answer = horzcat (varargin)
    varargin = cellfun(@defrontal, varargin, ...
        'UniformOutput',false);
    answer = frontal(horzcat(varargin{:}));
end

