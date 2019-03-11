function Y = difffwd (X, n, dim, opt)
    if (nargin < 2) || isempty(n),  n = 1;  end
    if (nargin < 3) || isempty(dim),  dim = finddim(X);  end
    if (nargin < 4) || isempty(opt),  opt = 'fwd';  end
    Y = diff(X, n, dim);
    siz = size(Y);
    siz(dim) = 1;
    temp = NaN(siz);
    if strcmp(opt, 'fwd')
        Y = cat(dim, Y, temp);
    else
        Y = cat(dim, temp, Y);
    end
end
