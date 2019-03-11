function varargout = snr_setup_ant_phase (varargin)
    [varargout{1:nargout}] = snr_setup_ant_comp ('phase', varargin{:});
end
