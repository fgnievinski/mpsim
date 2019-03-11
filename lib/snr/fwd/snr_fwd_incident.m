function varargout = snr_fwd_incident (geom, setup)
%SNR_FWD_INCIDENT: Return incident electric field (units V/m).

    opt = setup.opt;
    ant = setup.ant;
    
    power = snr_fwd_incident_power (geom, setup);
    power_density_spatial = power ./ ant.eff_len_norm_iso^2;  % in W/m^2
    magnitude = sqrt(power_density_spatial);  % in V/m
    [phasor_rhcp, phasor_lhcp] = jvec_init (...
        magnitude, opt.incid_polar_power, opt.incid_polar_phase);
      
    switch nargout
    case 2
        varargout = {phasor_rhcp, phasor_lhcp};
    case 1
        varargout = {struct('phasor_rhcp',phasor_rhcp, 'phasor_lhcp',phasor_lhcp)};
    end
end

