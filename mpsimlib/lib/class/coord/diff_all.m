function c = diff_all (F, n)
    if (nargin < 2) || isempty(n),  n = 1;  end
    c = diff(F, n, 1);
end
