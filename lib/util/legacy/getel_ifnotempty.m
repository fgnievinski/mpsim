% (this is just an interface)
function varargout = getel_ifnotempty (varargin)
    [varargout{1:nargout}] = getelif_nonempty (varargin{:});
end


