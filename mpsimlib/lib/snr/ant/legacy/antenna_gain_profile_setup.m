% (this is just an interface)
function varargout = antenna_gain_profile_setup (varargin)
    [varargout{1:nargout}] = snr_setup_ant_profile_load (varargin{:});
end

