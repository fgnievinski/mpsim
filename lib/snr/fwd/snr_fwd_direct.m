function [phasor, extra] = snr_fwd_direct (...
incident, geom, setup)
    [phasor_antenna_rhcp, phasor_antenna_lhcp] = snr_fwd_antenna (...
        'direct', geom, setup);

    phasor_rhcp = phasor_antenna_rhcp .* incident.phasor_rhcp;
    phasor_lhcp = phasor_antenna_lhcp .* incident.phasor_lhcp;

    phasor = phasor_rhcp + phasor_lhcp;
    
    extra.phasor_antenna_rhcp = phasor_antenna_rhcp;
    extra.phasor_antenna_lhcp = phasor_antenna_lhcp;
    extra.phasor_rhcp = phasor_rhcp;
    extra.phasor_lhcp = phasor_lhcp;
end

