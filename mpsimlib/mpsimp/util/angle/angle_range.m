% (this is just an interface)
function varargout = angle_range (varargin)
    [varargout{1:nargout}] = angle_range_negative_positive (varargin{:});
end



