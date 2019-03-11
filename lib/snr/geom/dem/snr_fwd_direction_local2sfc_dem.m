function [dir_sfc, optimizeit, economic] = snr_fwd_direction_local2sfc_dem (...
dir_local, setup, geom) %#ok<INUSL>
    sfc = setup.sfc;
    opt = setup.opt;
    if ~isfield(sfc, 'optimizeit'),  sfc.optimizeit = [];  end
    if ~isfield(sfc, 'economic'),  sfc.economic = [];  end
    if isfieldempty(geom.reflection.extra, 'height_grad')
        geom.reflection.extra.height_grad = snr_fwd_geometry_height_grad (...
            geom.reflection.pos, sfc);
    end
    if sfc.economic
        rot = [];
        slope = [];
        aspect = [];
        dir_nrml.cart = horizgrad2sfcnrml (geom.reflection.extra.height_grad);
    else
        [rot, dir_nrml, slope, aspect] = get_rotation_matrix4_local (...
            geom.reflection.extra.height_grad);
    end
    [dir_sfc, optimizeit, economic] = snr_fwd_direction_local2 (...
        length(dir_local.elev), dir_local, rot, dir_nrml, aspect, slope, [], ...
        sfc.optimizeit, sfc.economic);
end

