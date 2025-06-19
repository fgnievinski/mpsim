function x = sphharm_fit_constrain (pos_sph, b, n, CA, A)
    if (nargin < 5) || isempty(A),  A = sphharm_design (pos_sph, n); end
    N = A' * A + inv(CA);
    u = A' * b;
    x = N \ u;
    %x = A \ b;
end

