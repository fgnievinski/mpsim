function varargout = frontal_eigs (A, varargin)
    [varargout{1:nargout}] = frontal_func(@eigs, A, varargin{:});
end
