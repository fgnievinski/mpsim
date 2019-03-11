function [c, endcond] = splinefit2c (bx, by, x, y, z, endcond, method, varargin)
    if (nargin < 6),  endcond = [];  end
    if (nargin < 7),  method = [];  end
    A = splinedesign2a (bx, by, x(:), y(:), endcond);
    N = A'*A;  n = diag(N);  n = max(n, nthroot(eps(), 3));  C = diag(n);
    c = fit2 (A, z, method, C, varargin{:});
    c = reshape(c, length(by), length(bx));
    % (following meshgrid usage in splinedesign2a.)
end

