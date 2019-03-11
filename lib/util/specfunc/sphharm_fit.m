function [x, A] = sphharm_fit (pos_sph, b, n, A)
    if (nargin < 4) || isempty(A),  A = sphharm_design (pos_sph, n); end
    x = A \ b;
end

