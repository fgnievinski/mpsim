function varargout = xlimsininv (lim)
    if (nargin < 1),  lim = [];  end
    fncs = {@(e) 1./sind(e) @(x) asind(1./x)};
    [varargout{1:nargout}] = xlimsin (lim, fncs);
end
