function [c, endcond] = splinefit2 (bx, by, x, y, z, endcond, method, varargin)
    if (nargin < 6),  endcond = [];  end
    if (nargin < 7),  method = [];  end
    A = splinedesign2a (bx, by, x(:), y(:), endcond);
    c = fit2 (A, z, method, varargin{:});
    c = reshape(c, length(by), length(bx));
    % (following meshgrid usage in splinedesign2a.)
end

