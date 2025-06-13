function varargout = arrayfun2 (varargin)
    [varargout{1:nargout}] = arrayfun(varargin{:}, 'UniformOutput',false);
end
