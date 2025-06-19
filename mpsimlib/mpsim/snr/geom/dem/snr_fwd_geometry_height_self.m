function height = snr_fwd_geometry_height_self (sfc_pos_horiz, sfc)
    sfc_pos_horiz = neu2xyz(sfc_pos_horiz);
    x_pos = sfc_pos_horiz(:,1);
    y_pos = sfc_pos_horiz(:,2);
    
    height = sfc.snr_fwd_geometry_height_self_aux(x_pos, y_pos, sfc);

    if sfc.dem_is_relative,  height = height - sfc.height0;  end
end

