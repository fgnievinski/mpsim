% (this is just an interface)
function varargout = antenna_gain_densemap_setup (varargin)
    [varargout{1:nargout}] = snr_setup_ant_densemap_load (varargin{:});
end

