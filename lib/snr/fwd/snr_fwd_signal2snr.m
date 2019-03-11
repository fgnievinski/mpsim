function [CPN_db, power_loss] = snr_fwd_signal2snr (power_signal, setup, geom, phasor_bias_direct)
    opt = setup.opt;
    % Nomenclature: variable names are formed as "quantity type"_"specific
    % usage", e.g., power_noise or power_carrier; this corresponds exactly
    % to the use of subscripts in mathematical notation, e.g., P_N, P_C.

    % Noise spectral power density (in W/Hz):
    density_noise_postant = opt.rec.snr_fwd_ant_density_noise (setup);
    density_noise = density_noise_postant + ...
       get_standard_constant('boltzmann') * opt.rec.temperature_noise;

    % Carrier-to-noise-density ratio (in hertz):
    CN0 = power_signal ./ density_noise;
   
    % Noise bandwidth (in hertz):
    bandwidth_noise = opt.rec.snr_fwd_bandwidth_noise (setup);
    
    % Carrier-to-noise ratio $C/P_N = C/(N_0 B_N) = (C/N_0)/B_N$ (in watts per watt)
    CPN = CN0 ./ bandwidth_noise;
    %power_noise = density_noise * bandwidth_noise;
    %CPN = power_signal_postant ./ power_noise;

    % Fixed bias:
    CPN = CPN .* snr_fwd_bias_fixed (setup, geom);

    % Tracking losses (due to, e.g., P(Y) semi-codeless tracking):
    CPN = opt.rec.snr_fwd_tracking_loss (CPN, setup);
    
    % Account for distortion introduced by SNR estimator:
    CPN = opt.rec.snr_fwd_estimator (CPN, setup);
    
    % Modified noise power (original noise power and all other losses):
    power_loss = power_signal ./ CPN;

    CPN_db = decibel_power(CPN);
    
    if setup.bias.apply_direct_power_bias_only_at_end
        temp = decibel_phasor (phasor_bias_direct, false);
        if setup.bias.inv_ratio,  temp = -temp;  end
        CPN_db = CPN_db - temp;
    end
end
