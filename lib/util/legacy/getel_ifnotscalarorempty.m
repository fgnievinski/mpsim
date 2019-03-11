% (this is just an interface)
function varargout = getel_ifnotscalarorempty (varargin)
    [varargout{1:nargout}] = getelif_nonscalar_nonempty (varargin{:});
end


