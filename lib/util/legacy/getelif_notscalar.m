% (this is just an interface)
function varargout = getelif_notscalar (varargin)
    [varargout{1:nargout}] = getelif_notscalarorempty (varargin{:});
end

