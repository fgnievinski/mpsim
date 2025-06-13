% (this is just an interface)
function varargout = normalize_vec (varargin)
    [varargout{1:nargout}] = normalize_all (varargin{:});
end

