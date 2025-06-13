function power_bias = snr_fwd_bias_fixed (setup, geom)
    indep = snr_bias_indep (setup.bias, setup.sat, geom);
    power_bias = snr_bias_power_eval (setup.bias.fixed, indep);
end


