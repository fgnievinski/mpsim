% (this is just an interface)
function varargout = calc_diffraction_series (varargin)
    [varargout{1:nargout}] = calc_diffraction_series2 (varargin{:});
end

