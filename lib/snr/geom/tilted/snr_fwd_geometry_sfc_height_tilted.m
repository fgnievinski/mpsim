function [height, optimizeit] = snr_fwd_geometry_sfc_height_tilted (pos_sfc_horiz, setup)
    sfc = setup.sfc;
    ref = setup.ref;
    if isfieldempty(sfc, 'optimizeit'),  sfc.optimizeit = true;  end
    optimizeit = sfc.optimizeit;
    %optimizeit = false;  % DEBUG
    if sfc.optimizeit && (sfc.slope == 0)
        setup.sfc = snr_setup_sfc_geometry_horiz (ref.pos_ant, sfc.pos_sfc0);
        height = snr_fwd_geometry_sfc_height_horiz (pos_sfc_horiz, setup);
        return;
    end

    height = plane_eval(pos_sfc_horiz, sfc.pos_sfc0, sfc.vec_nrml.cart);
end

