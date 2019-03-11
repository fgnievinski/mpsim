function [c, endcond, A] = splinefit (bx, x, z, endcond, method, varargin)
    if (nargin < 4),  endcond = [];  end
    if (nargin < 5),  method = [];  end
    A = splinedesign1a (bx, x(:), endcond);
    c = fit2 (A, z, method, varargin{:});
end

