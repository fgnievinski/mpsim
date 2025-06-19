function [x, A] = sphharmreal_fit (pos_sph, b, n, A)
    if (nargin < 4) || isempty(A),  A = sphharmreal_design (pos_sph, n); end
    x = A \ b;
end

