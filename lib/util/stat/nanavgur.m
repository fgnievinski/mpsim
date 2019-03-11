% (this is just an interface)
function varargout = nanavgur (varargin)
    [varargout{1:nargout}] = nanmeanur (varargin{:});
end

