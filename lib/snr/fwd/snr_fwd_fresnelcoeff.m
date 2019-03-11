function [phasor_same, phasor_cross] = snr_fwd_fresnelcoeff (geom, setup)
    sfc = setup.sfc;
    opt = setup.opt;
    if ~isfield(sfc, 'permittivity_top'),  sfc.permittivity_top = [];  end
    if ~isfield(sfc, 'permittivity_middle'),  sfc.permittivity_middle = [];  end
    %dir = geom.direct.dir.local_ant;  % WRONG!
    dir = geom.reflection.sat_dir.sfc;
    [phasor_same, phasor_cross] = sfc.fnc_get_reflection_coeff (...
        dir.elev, sfc.permittivity_bottom, ...
        sfc.permittivity_top, sfc.permittivity_middle, sfc, opt);
    if isfield(opt, 'reflect_coeff_cross_only') ...
    && opt.reflect_coeff_cross_only
        phasor_same(:) = 0;
    end
    % DEBUG:
    %phasor_same  = real(phasor_same);
    %phasor_cross = real(phasor_cross);
    %phasor_same  = complex(0, imag(phasor_same));
    %phasor_cross = complex(0, imag(phasor_cross));
    %phasor_same  = ones(size(setup.sat.epoch));
    %phasor_cross = ones(size(setup.sat.epoch));
end

