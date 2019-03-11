function [phasor_bias, power_bias, phase_bias] = snr_fwd_bias_trend (setup, geom)
    indep = snr_bias_indep (setup.bias, setup.sat, geom);
    wavelength = setup.opt.wavelength;
    phase_bias = snr_bias_phase_eval (setup.bias.phase_direct, indep, wavelength);
    power_bias = snr_bias_power_eval (setup.bias.power_direct, indep);
    phasor_bias = phasor_init(sqrt(power_bias), phase_bias);
end


