% (this is just an interface)
function varargout = getelif_notempty (varargin)
    [varargout{1:nargout}] = getelif_notscalarorempty (varargin{:});
end

