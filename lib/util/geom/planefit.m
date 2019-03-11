% (this is just an interface)
function varargout = planefit (varargin)
    [varargout{1:nargout}] = plane_fit (varargin{:});
end

%!test
%! % just check whether it runs:
%! planefit(1);

