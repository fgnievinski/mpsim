function answer = sphharmreal_eval (pos_sph, coeff, n, A)
    if (nargin < 4) || isempty(A),  A = sphharmreal_design (pos_sph, n); end
    answer = A * coeff;
end

