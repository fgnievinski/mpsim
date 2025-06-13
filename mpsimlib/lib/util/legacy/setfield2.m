% (this is just an interface)
function varargout = setfield2 (varargin)
    [varargout{1:nargout}] = setfields (varargin{:});
end


