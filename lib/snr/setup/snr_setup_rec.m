function rec = snr_setup_rec (sett_rec)
    rec = sett_rec;  clear sett_rec
    rec.ant_density_noise = decibel_power_inv(rec.ant_density_noise_db);
    
    rec.snr_fwd_tracking_loss         = @snr_fwd_tracking_loss;
    rec.snr_fwd_estimator             = @snr_fwd_estimator;
    rec.snr_fwd_rec_temperature_noise = @snr_fwd_rec_temperature_noise;
    rec.snr_fwd_bandwidth_noise       = @snr_fwd_bandwidth_noise;
    rec.snr_fwd_ant_density_noise     = @snr_fwd_ant_density_noise;
end

function CPN_estim = snr_fwd_estimator (CPN_true, setup) %#ok<INUSD>
    % assume ideal estimator:
    CPN_estim = CPN_true;
    % TODO: really account for distortion introduced by actual SNR estimators.
end

function F = snr_fwd_rec_temperature_noise (setup) %#ok<*INUSL>
    % In the lack of a better prediction, we will return 
    % a nominal, user-provided value:
    F = setup.opt.rec.temperature_noise;
end

% Noise bandwidth:
function bandwidth_noise = snr_fwd_bandwidth_noise (setup)
    % In the lack of a better prediction, we will return 
    % a nominal, user-provided value, presumably constant.
    bandwidth_noise = setup.opt.rec.bandwidth_noise;
end

% Post-antenna noise spectral density:
function density_noise = snr_fwd_ant_density_noise (setup)
    % In the lack of a better prediction, we will return 
    % a nominal, user-provided value, presumably constant.
    density_noise = setup.opt.rec.ant_density_noise;
end

