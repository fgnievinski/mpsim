function height = snr_fwd_geometry_sfc_height_horiz (pos, setup)
    height = repmat(setup.sfc.pos_sfc0(3), [size(pos,1),1]);
end

