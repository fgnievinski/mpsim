function varargout = cellfun2 (varargin)
    [varargout{1:nargout}] = cellfun(varargin{:}, 'UniformOutput',false);
end
