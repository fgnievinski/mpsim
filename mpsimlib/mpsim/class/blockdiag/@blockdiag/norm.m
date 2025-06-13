function answer = norm (A, p)
    if (nargin < 2),  p = 2;  end  % Matlab's norm() behaviour
    answer = cellfun(@(a) norm(a, p), diag(cell(A)));
    answer = max(abs(answer));
    myassert(isscalar(answer))
end

