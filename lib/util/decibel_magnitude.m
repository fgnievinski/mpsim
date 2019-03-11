% (this is just an interface)
function varargout = decibel_magnitude (varargin)
    [varargout{1:nargout}] = decibel_rootpower (varargin{:});
end


