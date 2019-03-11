function s = corrauxscalar(S, i, j)
    if (nargin < 2) || isempty(i),  i = 1;  end
    if (nargin < 3) || isempty(j),  j = 2;  end
    s = S(i,j);
end

