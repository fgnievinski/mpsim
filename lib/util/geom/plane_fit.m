function [coeff, slope, aspect, z_fit, z_res, rmsr, rmsz, var_red] = plane_fit (x, y, z, method, varargin)
    if (nargin < 4),  method = [];  end
    if isvector(x) && isvector(y) && ~isvector(z),  [x, y] = meshgrid(x, y);  end
    N = numel(x);  myassert(numel(y), N);  myassert(numel(z), N);
    A = horzcat(ones(N,1), x(:), y(:));
    coeff = fit2 (A, z(:), method, varargin{:});
    % Here we use a bi-variate linear fit, f(x,y) = c00 + c01*x + c10*y;
    % NOT a bi-linear fit: f(x,y) = c00 + c01*x + c10*y + c11*x*y;
    if (nargout < 2),  return;  end
    dz_dx = coeff(2);
    dz_dy = coeff(3);
    [slope, aspect] = horizgrad2slopeaspect(dz_dx, dz_dy);
    if (nargout < 4),  return;  end
    z_fit = coeff(1) + coeff(2) * x + coeff(3) * y;
    if (nargout < 5),  return;  end
    z_res = z - z_fit;
    if (nargout < 6),  return;  end
    rmsr = nanrmse(z_res(:));
    rmsz = nanrmse(z(:));
    var_red = 1 - rmsr^2/rmsz^2;
 end

