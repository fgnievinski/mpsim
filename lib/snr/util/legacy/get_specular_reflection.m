% (this is just an interface)
function varargout = get_specular_reflection (varargin)
    [varargout{1:nargout}] = get_reflection_point (varargin{:});
end

