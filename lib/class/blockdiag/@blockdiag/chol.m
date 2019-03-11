function A = chol (A, varargin)
    A = diag(cell(A));
    A = cellfun(@(a) chol(a, varargin{:}), A, ...
        'UniformOutput',false);
    A = blockdiag(A);
end

