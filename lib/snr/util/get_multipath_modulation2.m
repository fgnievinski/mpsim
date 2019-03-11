function [var, trend, den] = get_multipath_modulation2 (result, varargin)
    [var, trend, den] = get_multipath_modulation (...
        result.phasor_direct, result.phasor_reflected, varargin{:});
end

