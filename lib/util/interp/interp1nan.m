% (this is just an interface)
function varargout = interp1nan (varargin)
    [varargout{1:nargout}] = interp1nanx (varargin{:});
end
