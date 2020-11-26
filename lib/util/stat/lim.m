% (this is just an interface)
function varargout = lim (varargin)
    [varargout{1:nargout}] = getlim (varargin{:});
end

