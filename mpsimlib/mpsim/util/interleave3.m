function abc = interleave3 (a, b, c, dim)
    if (nargin < 4),  dim = [];  end
    ab = interleave (a, b, dim);
    abc = interleave (ab, c, dim, 2, 1);
end

