function s = corrcoefscalar(x, y, varargin)
    S = corrcoef(x, y);
    s = corrauxscalar(S, varargin{:});
end

