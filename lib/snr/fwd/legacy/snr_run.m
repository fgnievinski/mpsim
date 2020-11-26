% (this is just an interface)
function varargout = snr_run (varargin)
    [varargout{1:nargout}] = snr_fwd (varargin{:});
end

