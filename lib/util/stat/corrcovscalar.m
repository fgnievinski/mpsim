function s = corrcovscalar(C, varargin)
    S = corrcov(C);
    s = corrauxscalar(S, varargin{:});
end

