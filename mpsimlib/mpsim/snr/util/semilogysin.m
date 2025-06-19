function varargout = semilogysin (varargin)
    [varargout{1:nargout}] = plotsin(varargin{:});
    set(gca(), 'YScale','log')
end