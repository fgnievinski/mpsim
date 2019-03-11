% (this is just an interface)
function varargout = invsort (varargin)
    [varargout{1:nargout}] = argsort (varargin{:});
end

