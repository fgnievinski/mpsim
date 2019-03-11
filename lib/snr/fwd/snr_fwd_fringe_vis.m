function result = snr_fwd_fringe_vis (result, varargin)
    result.fringe_vis = get_fringe_vis (...
        result.phasor_direct, result.phasor_reflected, varargin{:});
end

