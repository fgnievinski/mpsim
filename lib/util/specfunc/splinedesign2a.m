function [A, endcond] = splinedesign2a (bx, by, xi, yi, endcond)
    if (nargin < 5),  endcond = [];  end
    Nx = length(bx);
    Ny = length(by);

    n = numel(xi);
    %myassert(numel(yi), n);
    if (Nx * Ny == 0)
        A = zeros(n,0);
        return;
    end

    % basis on bx, by:
    temp = [repmat(endcond, Nx, 1), eye(Nx), repmat(endcond, Nx, 1)];
    Bx = spline(bx, temp, xi).';
    temp = [repmat(endcond, Ny, 1), eye(Ny), repmat(endcond, Ny, 1)];
    By = spline(by, temp, yi).';
    if isscalar(yi),  By = repmat(By, length(xi),1);  end

    % products of basis of bx, by:
    [Ix, Iy] = meshgrid(1:Nx, 1:Ny);
    A = Bx(:,Ix(:)) .* By(:,Iy(:));
      myassert(size(A, 2), Nx*Ny)
    % (see polydesign2a for simpler yet slower implementations)
end

