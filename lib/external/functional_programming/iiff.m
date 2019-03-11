function varargout = iiff(varargin)
    varargin(end:end+1) = [{true}, varargin(end)];
    [varargout{1:nargout}] = iif(varargin{:});
end
