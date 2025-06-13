function phasor_rough = snr_fwd_roughness (geom, setup) %#ok<INUSL>
    if ~isfield(setup.sfc, 'height_std'),  setup.sfc.height_std = [];  end
    %dir = geom.direct.dir.local_ant;  % WRONG!
    dir = geom.reflection.sat_dir.sfc;
    phasor_rough = get_roughness (setup.sfc.height_std, setup.opt.wavelength, dir.elev);
end
