function X = triinv (Q, opt, varargin)
    X = cellfun(@(a) triinv (a, opt, varargin{:}), diag(cell(Q)), ...
        'UniformOutput', false);
    X = blockdiag(X);
end
