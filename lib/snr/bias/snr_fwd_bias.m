function [phasor_direct, phasor_bias_direct_original, ...
phasor_reflected, phasor_bias_reflected_original, ...
delay_reflected, delay_bias] = ...
snr_fwd_bias (phasor_direct, phasor_reflected, delay_reflected, setup, geom)
    [phasor_bias_direct, power_bias_direct] = snr_fwd_bias_trend (setup, geom);
    [phasor_bias_interf, delay_bias] = snr_fwd_bias_fringe (setup, geom);
    phasor_bias_reflected = phasor_bias_direct .* phasor_bias_interf; 
    
    phasor_bias_direct_original = phasor_bias_direct;
    phasor_bias_reflected_original = phasor_bias_reflected;
    if setup.bias.apply_direct_power_bias_only_at_end
        magn_bias_direct = sqrt(power_bias_direct);
        phasor_bias_direct    = phasor_bias_direct    ./ magn_bias_direct;
        phasor_bias_reflected = phasor_bias_reflected ./ magn_bias_direct;
    end

    op = @rdivide;
    op2 = @minus;
    if setup.bias.inv_ratio
        op = @times;
        op2 = @plus;
    end
    phasor_direct    = bsxfun(op, phasor_direct,    phasor_bias_direct);
    phasor_reflected = bsxfun(op, phasor_reflected, phasor_bias_reflected);
    delay_reflected  = bsxfun(op2, delay_reflected, delay_bias);
end
