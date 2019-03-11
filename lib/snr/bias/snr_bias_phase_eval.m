function [phase_bias, delay_bias] = snr_bias_phase_eval (coeff, indep, wavelength, calc_delay, return_scalar)
    if (nargin < 5),  return_scalar = [];  end
    phase_bias = snr_bias_poly_eval (coeff, indep, return_scalar);
    delay_bias = 0;
    if (nargin < 4) || isempty(calc_delay) || ~calc_delay,  return;  end
    delay_bias = phase2delay (phase_bias, wavelength);
end

