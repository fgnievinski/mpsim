function Q = unwrapd (P, tol, varargin)
    if (nargin < 2) || isempty(tol),  tol = 180;  end
    Q = unwrap(P*pi/180, tol*pi/180, varargin{:})*180/pi;
end

