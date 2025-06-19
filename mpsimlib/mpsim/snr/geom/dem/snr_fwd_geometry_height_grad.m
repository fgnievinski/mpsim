function grad = snr_fwd_geometry_height_grad (sfc_pos_horiz, sfc)
    sfc_pos_horiz = neu2xyz(sfc_pos_horiz);
    x_pos = sfc_pos_horiz(:,1);
    y_pos = sfc_pos_horiz(:,2);

    [dz_dx, dz_dy] = sfc.snr_fwd_geometry_height_grad_aux(x_pos, y_pos, sfc);

    grad = xyz2neu(dz_dx, dz_dy);
end

