function [phasor_bias, delay_bias] = snr_fwd_bias_fringe (setup, geom)
    [indep, graz] = snr_bias_indep (setup.bias, setup.sat, geom);
    wavelength = setup.opt.wavelength;

    [phase_bias0, delay_bias0, height_bias0] = snr_bias_phase_eval (...
        setup.bias.phase_interf, indep, wavelength);
    
    [phase_bias1, delay_bias1, height_bias1] = snr_bias_height_eval (...
        setup.bias.height, indep, wavelength, graz);
    
    [phase_bias2, delay_bias2, height_bias2] = snr_bias_chirp_eval (...
        setup.bias.chirp, setup.bias.indep_mid, indep, wavelength, graz);
    
    phase_bias = phase_bias0 + phase_bias1 + phase_bias2;
    delay_bias = delay_bias0 + delay_bias1 + delay_bias2;
    height_bias = height_bias0 + height_bias1 + height_bias2;
    %if ~all(height_bias==0),  fpk indep height_bias;  end  % DEBUG
    
    power_bias = snr_bias_power_eval (setup.bias.power_interf, indep);
  
    phasor_bias = phasor_init(sqrt(power_bias), phase_bias);
end

