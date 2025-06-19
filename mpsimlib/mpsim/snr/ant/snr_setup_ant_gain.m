function varargout = snr_setup_ant_gain (varargin)
    [varargout{1:nargout}] = snr_setup_ant_comp ('gain', varargin{:});
end
