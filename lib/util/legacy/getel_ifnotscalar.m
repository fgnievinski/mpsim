% (this is just an interface)
function varargout = getel_ifnotscalar (varargin)
    [varargout{1:nargout}] = getelif_nonscalar (varargin{:});
end

