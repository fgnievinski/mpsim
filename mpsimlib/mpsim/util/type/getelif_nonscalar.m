% (this is just an interface)
function varargout = getelif_nonscalar (varargin)
    [varargout{1:nargout}] = getelif_nonscalar_nonempty (varargin{:});
end

