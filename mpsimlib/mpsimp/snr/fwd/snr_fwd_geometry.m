function geom = snr_fwd_geometry (setup)
    geom = struct();
    geom.num_dirs = numel(setup.sat.elev);
    geom.num_reflections = min(setup.sfc.num_specular_max, setup.opt.num_specular_max);
    geom.direct = snr_fwd_geometry_direct (setup, geom);
    for i=1:geom.num_reflections
        geom.reflections(i) = snr_fwd_geometry_reflected (i, setup, geom);
    end
end

function direct = snr_fwd_geometry_direct (setup, geom)
    direct.dir.local_ant = setup.sat.get_direction (setup);
    direct.dir.local_ant.sph = [direct.dir.local_ant.elev, direct.dir.local_ant.azim, ...
        ones(geom.num_dirs, 1)];
    direct.dir.local_ant.cart = sph2cart_local (direct.dir.local_ant.sph);
    direct.dir.ant = setup.ant.snr_fwd_direction_local2ant (...
        direct.dir.local_ant, setup);
    geom.direct = direct;  % snr_fwd_visibility needs this.
    direct.visible = setup.sfc.snr_fwd_visibility (setup, geom, 'direct');
end
    
function reflection = snr_fwd_geometry_reflected (order, setup, geom)
    [reflection.dir.local_ant, reflection.pos.local, ...
     reflection.delay, reflection.doppler, reflection.extra] = ...
        setup.sfc.snr_fwd_geometry_reflection (...
        geom.direct.dir.local_ant, order, setup);
    reflection.dir.ant = setup.ant.snr_fwd_direction_local2ant (...
        reflection.dir.local_ant, setup);
    geom.reflection = reflection;  % snr_fwd_direction_local2sfc_dem needs this.
    reflection.sat_dir.sfc = setup.sfc.snr_fwd_direction_local2sfc (...
        geom.direct.dir.local_ant, setup, geom);
    geom.reflection = reflection;  % snr_fwd_visibility needs this (with sat_dir).
    reflection.visible = setup.sfc.snr_fwd_visibility (setup, geom, 'reflection');
end
