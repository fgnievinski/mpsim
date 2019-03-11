function [A, endcond] = splinedesign1a (bx, xi, endcond)
    if (nargin < 3),  endcond = [];  end
    Nx = length(bx);

    n = numel(xi);
    if (Nx == 0)
        A = zeros(n,0);
        return;
    end

    temp = [repmat(endcond, Nx, 1), eye(Nx), repmat(endcond, Nx, 1)];
    A = spline(bx, temp, xi).';
end

