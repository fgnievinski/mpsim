% (this is just an interface)
function varargout = nanavg (varargin)
    [varargout{1:nargout}] = nanmean (varargin{:});
end

