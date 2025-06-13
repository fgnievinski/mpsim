function c = difffwd_all (F, n)
    if (nargin < 2) || isempty(n),  n = 1;  end
    c = difffwd(F, n, 1);
end
