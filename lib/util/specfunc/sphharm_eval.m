function answer = sphharm_eval (pos_sph, coeff, n, A)
    if (nargin < 4) || isempty(A),  A = sphharm_design (pos_sph, n); end
    answer = A * coeff;
    answer = real(answer) + imag(answer);
end

