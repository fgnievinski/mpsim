function varargout = size (A, varargin)
    [varargout{1:nargout}] = size (A.data, varargin{:});
end
