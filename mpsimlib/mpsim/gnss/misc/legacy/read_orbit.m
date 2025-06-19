% (this is just an interface)
function varargout = read_orbit (varargin)
    [varargout{1:nargout}] = read_sp3 (varargin{:});
end

