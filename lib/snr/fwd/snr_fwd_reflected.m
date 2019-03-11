function [phasor, extra] = snr_fwd_reflected (incident, geom, setup)
    opt = setup.opt;
    extra = snr_fwd_reflected_aux (geom, setup);
       
    phasor_nongeom_rhcp = extra.phasor_antenna_rhcp ...
        .* ( incident.phasor_rhcp .* extra.phasor_fresnelcoeff_same ...
           + incident.phasor_lhcp .* extra.phasor_fresnelcoeff_cross );
    phasor_nongeom_lhcp = extra.phasor_antenna_lhcp ...
        .* ( incident.phasor_lhcp .* extra.phasor_fresnelcoeff_same ...
           + incident.phasor_rhcp .* extra.phasor_fresnelcoeff_cross );
       
    phasor_nongeom = phasor_nongeom_rhcp + phasor_nongeom_lhcp;
    
    phasor_geom = extra.phasor_delay .* extra.phasor_roughness .* extra.phasor_divergence;
    
    phasor = phasor_geom .* phasor_nongeom;
    
    extra.phasor_nongeom = phasor_nongeom;
    extra.phasor_rhcp = phasor_geom .* phasor_nongeom_rhcp;
    extra.phasor_lhcp = phasor_geom .* phasor_nongeom_lhcp;
end

function extra = snr_fwd_reflected_aux (geom, setup)
    phasor_delay = snr_fwd_delay (geom, setup);
    phasor_roughness = snr_fwd_roughness (geom, setup);
    phasor_divergence = setup.sfc.snr_fwd_divergence (geom, setup);
    
    [phasor_antenna_rhcp, phasor_antenna_lhcp] = snr_fwd_antenna (...
        'reflected', geom, setup);
    [phasor_fresnelcoeff_same, phasor_fresnelcoeff_cross] = ...
        snr_fwd_fresnelcoeff (geom, setup);
    
    extra.phasor_antenna_rhcp = phasor_antenna_rhcp;
    extra.phasor_antenna_lhcp = phasor_antenna_lhcp;
    extra.phasor_fresnelcoeff_same  = phasor_fresnelcoeff_same;
    extra.phasor_fresnelcoeff_cross = phasor_fresnelcoeff_cross;
    extra.phasor_delay = phasor_delay; 
    extra.phasor_roughness = phasor_roughness;
    extra.phasor_divergence = phasor_divergence;
end
