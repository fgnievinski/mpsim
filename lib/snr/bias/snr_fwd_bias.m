function [phasor_direct, phasor_bias_direct_original, ...
phasor_reflected, phasor_bias_reflected_original, ...
delay_reflected, delay_bias_original] = ...
snr_fwd_bias (phasor_direct, phasor_reflected, delay_reflected, setup, geom)
    phasor_bias_direct = snr_fwd_bias_trend (setup, geom);
    [phasor_bias_interf, delay_bias] = snr_fwd_bias_fringe (setup, geom);

    phasor_bias_direct_original = phasor_bias_direct;
    phasor_bias_interf_original = phasor_bias_interf;
    delay_bias_original = delay_bias;

    if setup.bias.inv_ratio_trend
        phasor_bias_direct = 1./phasor_bias_direct;
    end
    if setup.bias.inv_ratio_fringe
        phasor_bias_interf = 1./phasor_bias_interf;
        delay_bias = -delay_bias;
    end

    if setup.bias.apply_direct_power_bias_only_at_end
        % undo what will be done later in snr_fwd_signal2snr()
        phasor_bias_direct = divide_all(phasor_bias_direct, abs(phasor_bias_direct));
    end

    phasor_bias_reflected = phasor_bias_direct .* phasor_bias_interf;
    phasor_bias_reflected_original = phasor_bias_direct_original .* phasor_bias_interf_original; 
    
    phasor_direct    = divide_all(phasor_direct,    phasor_bias_direct);
    phasor_reflected = divide_all(phasor_reflected, phasor_bias_reflected);
    delay_reflected  =  minus_all(delay_reflected,  delay_bias);
end

