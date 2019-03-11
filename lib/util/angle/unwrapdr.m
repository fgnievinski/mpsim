function Q = unwrapdr (P, n, tol, varargin)
    if (nargin < 2),  n = [];  end
    if (nargin < 3) || isempty(tol),  tol = 180;  end
    Q = unwrapr (P*pi/180, n, tol*pi/180, varargin{:})*180/pi;
end

