function result = snr_fwd_fringe_dev (result, varargin)
    result.fringe_dev = get_fringe_dev (...
        result.phasor_direct, result.phasor_reflected, varargin{:});
end

