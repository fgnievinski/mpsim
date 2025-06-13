function Y = diffbwd (X, n, dim, opt)
    if (nargin < 2) || isempty(n),  n = 1;  end
    if (nargin < 3) || isempty(dim),  dim = finddim(X);  end
    if (nargin < 4) || isempty(opt),  opt = 'bwd';  end
    Y = difffwd (X, n, dim, opt);
end
