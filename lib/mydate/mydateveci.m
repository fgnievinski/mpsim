function varargout = mydateveci (varargin)
%MYDATEVECI: Convert from vector parts (to epoch in internal format).
    [varargout{1:nargout}] = mydatenum (varargin{:});
end

