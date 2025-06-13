% (this is just an interface)
function varargout = filescan (varargin)
    [varargout{1:nargout}] = loadscan (varargin{:});
end

