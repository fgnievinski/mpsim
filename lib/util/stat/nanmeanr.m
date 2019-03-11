% (this is just an interface)
function varargout = nanmeanr (varargin)
    [varargout{1:nargout}] = nanmedian (varargin{:});
end

