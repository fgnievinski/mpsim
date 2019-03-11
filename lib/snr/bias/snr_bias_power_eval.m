function [power_bias, power_bias_db] = snr_bias_power_eval (coeff, varargin)
    coeff = snr_bias_power_default (coeff);
    power_bias_db = snr_bias_poly_eval (coeff, varargin{:});
    power_bias = decibel_power_inv (power_bias_db);
end

