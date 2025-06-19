function power_bias_coeff = snr_bias_power_default (power_bias_coeff)
    if (nargin < 1),  power_bias_coeff = [];  end
    if any(isnan(power_bias_coeff(:))) ...
    || ~isreal(power_bias_coeff(:)) ...
    || ischar(power_bias_coeff(:))
        warning('snr:bias:power:badCoeff', 'Invalid coefficients detected.');
    end
end

