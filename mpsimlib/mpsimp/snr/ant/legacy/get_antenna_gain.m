% (this is just an interface)
function varargout = get_antenna_gain (varargin)
    [varargout{1:nargout}] = get_antenna_pattern (varargin{:});
end

