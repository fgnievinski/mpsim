function varargout = snr_fwd_combine (opt, ...
phasor_direct_pre, phasor_reflected_pre, delay_reflected, delay_rate_reflected, extra)
    if (nargin < 6),  extra = struct();  end
    
    [delay_composite, phasor_composite, ~, ...
     phasor_direct_post, phasor_reflected_post_all, phasor_reflected_post_net, ...
     code_direct, code_reflected] ...
        = snr_fwd_dsss (opt.dsss, ...
        phasor_direct_pre, phasor_reflected_pre, delay_reflected, delay_rate_reflected);
    phasor_reflected_post = phasor_reflected_post_net;  % one scalar per direction.
    %phasor_reflected_post = phasor_reflected_post_all;  % one (row) vector per direction.
      
    extra.delay_composite = delay_composite;
    extra.phasor_composite = phasor_composite;
    extra.phasor_direct = phasor_direct_post;
    extra.phasor_reflected = phasor_reflected_post;
    
    extra.delay_direct = 0;
    extra.delay_reflected = delay_reflected;
    extra.delay_error  = extra.delay_composite - extra.delay_direct;
    extra.delay_interf = extra.delay_reflected - extra.delay_direct;
    extra.phasor_error  = extra.phasor_composite ./ extra.phasor_direct;
    extra.phasor_interf = extra.phasor_reflected ./ extra.phasor_direct;
        
    extra.direct.code = code_direct;
    extra.direct.phasor_pre = phasor_direct_pre;
    extra.direct.phasor_post = phasor_direct_post;
    extra.reflected.code = code_reflected;
    extra.reflected.phasor_pre = phasor_reflected_pre;
    extra.reflected.phasor_post = phasor_reflected_post;
    extra.reflected.phasor_post_net = phasor_reflected_post_net;
    extra.reflected.phasor_post_all = phasor_reflected_post_all;
    
    if ~opt.phase_approx_small_power
        phase_error = get_phase(extra.phasor_error);
    else
        phase_error = imag(extra.phasor_interf);
        %magn_interf = abs(extra.phasor_interf);
        %phase_interf = get_phase(extra.phasor_interf);
        %phase_error = magn_interf .* sind(phase_interf);
        phase_error = phase_error * 180/pi;  % our phase units convention.
    end
    
    power_composite = get_power(extra.phasor_composite);
    carrier_error   = phase_error .* opt.wavelength ./ 360;
    code_error      = extra.delay_error;
    
    if (nargout > 1)
        varargout = {power_composite, carrier_error, code_error, extra};
    else
        extra.power_composite = power_composite;
        extra.carrier_error = carrier_error;
        extra.code_error = code_error;
        varargout = {extra};
    end
end

