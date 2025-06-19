function y = logspace2 (a, b, n)
    if (nargin < 3),  n = 100;  end
    y = logspace (log10(a), log10(b), n);
end

