function answer = snr_setup_ant_sphharm_eval (elev, azim, data)
    answer = sphharm_eval ([elev, azim], data.final_coeff, data.n);
end

