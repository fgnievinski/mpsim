% (this is just an interface)
function varargout = normalize_pt (varargin)
    [varargout{1:nargout}] = normalize_all (varargin{:});
end

