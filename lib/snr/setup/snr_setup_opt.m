function opt = snr_setup_opt (sett_opt)
    [sett_opt.gnss_name, sett_opt.freq_name, sett_opt.channel, ...
     sett_opt.block_name, sett_opt.code_name, sett_opt.subcode_name] = ...
        snr_setup_signal_name (...
            sett_opt.gnss_name, sett_opt.freq_name, sett_opt.channel, ...
            sett_opt.block_name, sett_opt.code_name, sett_opt.subcode_name);
    opt = sett_opt;

    [opt.wavelength, opt.frequency] = get_gnss_constant (...
        opt.gnss_name, opt.freq_name, opt.channel);
    
    if isempty(opt.incid_polar_power)  % (use zero to force disabling it)
        [~, ~, ~, opt.incid_polar_power] = get_gnss_polar_ellipticity (...
            opt.gnss_name, opt.freq_name, opt.block_name);
    end
    
    opt = snr_fwd_incident_power_init (opt);
    
    opt.dsss.chip_width = get_gnss_code_sizes (opt.gnss_name, ...
        opt.code_name, opt.subcode_name, opt.freq_name);
    
    opt2 = getfields(sett_opt, {'disable_tracking_loss',...
        'freq_name','block_name','code_name','subcode_name'});
    opt.tracking_loss_data = snr_setup_tracking_loss (opt2);
    
    opt.rec = snr_setup_rec (sett_opt.rec);
    
    if isempty(opt.num_specular_max),  opt.num_specular_max = Inf;  end
end

