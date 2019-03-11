% (this is just an interface)
function varargout = getel_ifnotchar (varargin)
    [varargout{1:nargout}] = getelif_nonchar (varargin{:});
end

