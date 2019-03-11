% (this is NOT just an interface)
% forward and inverse are exactly the same.
function varargout = neu2xyz (varargin)
    [varargout{1:nargout}] = xyz2neu (varargin{:});
end
