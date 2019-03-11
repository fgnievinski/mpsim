% (this is just an interface)
function varargout = antenna_gain_sphharm_setup (varargin)
    [varargout{1:nargout}] = snr_setup_ant_sphharm_load (varargin{:});
end

