% (this is just an interface)
function varargout = decibel_magnitude_inv (varargin)
    [varargout{1:nargout}] = decibel_rootpower_inv (varargin{:});
end


