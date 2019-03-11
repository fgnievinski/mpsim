% (this is just an interface)
function varargout = read_orbit_file (varargin)
    [varargout{1:nargout}] = read_sp3 (varargin{:});
end

