function hess = snr_fwd_geometry_height_hess (sfc_pos_horiz, sfc)
    sfc_pos_horiz = neu2xyz(sfc_pos_horiz);
    x_pos = sfc_pos_horiz(:,1);
    y_pos = sfc_pos_horiz(:,2);

    [dz2_dx2, dz2_dy2, dz2_dxy] = sfc.snr_fwd_geometry_height_hess_aux(...
        x_pos, y_pos, sfc);

    dz2_dx2 = frontal_pt(dz2_dx2);
    dz2_dy2 = frontal_pt(dz2_dy2);
    dz2_dxy = frontal_pt(dz2_dxy);

    dz2_dyx = dz2_dxy;

    %hess = [dz2_dx2, dz2_dxy; dz2_dyx, dz2_dy2];  % WRONG!
    hess = [dz2_dy2, dz2_dyx; dz2_dxy, dz2_dx2];
end

