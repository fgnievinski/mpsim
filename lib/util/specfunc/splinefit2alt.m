function [c, endcond] = splinefit2alt (bx, by, x, y, z, endcond, f)
    if (nargin < 6),  endcond = [];  end
    if (nargin < 7),  f = 1;  end
    A = splinedesign2a (bx, by, x(:), y(:), endcond);
    N = A'*A;
    %Cxa = diag(diag(N)*f);
    var = diag(N) * f;
    Cxa = spdiags(var, 0, size(N,1), size(N,2));
    N2 = N + inv(Cxa);
    u = A'*z;
    c = N2 \ u;
    c = reshape(c, length(by), length(bx));
    % (following meshgrid usage in splinedesign2a.)
end

