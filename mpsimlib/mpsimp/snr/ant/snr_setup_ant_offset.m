function vec_apc_arp_upright = snr_setup_ant_offset (model, radome, freq_name)
    data_dir = snr_setup_ant_path();
    temp = snr_setup_ant_offset_load (data_dir);
    vec_apc_arp_upright = snr_setup_ant_offset_eval (temp, model, radome, freq_name);
end
