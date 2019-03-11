% (this is just an interface)
function varargout = mydategpsi (varargin)
    [varargout{1:nargout}] = mydategpswi (varargin{:});
end

%!test
%! % just check whether it runs:
%! mydategpswi(1, 2);




