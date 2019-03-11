function opt = snr_fwd_incident_power_init (opt)
    [opt.incident_power_min, opt.incident_power_min_elev] = get_gnss_power_min (...
        opt.gnss_name, opt.freq_name, opt.block_name, opt.code_name, opt.subcode_name);
      
    opt.incident_power_trend_data = get_gnss_power_trend_data (...
        opt.gnss_name, opt.freq_name, opt.block_name, opt.code_name, opt.subcode_name);
      
    geom2.direct.dir.local_ant.elev = opt.incident_power_min_elev;
    opt.incident_power_trend_min = snr_fwd_incident_power_trend (geom2, struct('opt',opt));
    %opt.incident_power_trend_min = snr_fwd_incident_power (geom2, struct('opt',opt));  % WRONG!
end

