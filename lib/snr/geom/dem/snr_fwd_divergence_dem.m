function phasor_divergence = snr_fwd_divergence_dem (geom, setup)
    dir_nrml.cart = horizgrad2sfcnrml (geom.reflection.extra.height_grad);

    %dz_dx = height_grad(:,1);  % WRONG!
    %dz_dy = height_grad(:,2);  % WRONG!
    [dz_dx, dz_dy] = neu2xyz(geom.reflection.extra.height_grad);

    % As per snr_fwd_geometry_height_hess:
    % hess = [dz_dxx, dz_dxy; dz_dyx, dz_dyx];  % WRONG!
    % hess = [dz_dyy, dz_dyx; dz_dxy, dz_dxx];
    dz_dyy = reshape(geom.reflection.extra.height_hess(1,1,:), [],1);
    dz_dxx = reshape(geom.reflection.extra.height_hess(2,2,:), [],1);
    dz_dxy = reshape(geom.reflection.extra.height_hess(2,1,:), [],1);
    
    dist_scatt = geom.reflection.extra.dist_scatt;
    dir_sat_cart = geom.reflection.sat_dir.sfc.cart;
    phasor_divergence = get_divergence (...
        dist_scatt, dir_sat_cart, dir_nrml.cart, ...
        dz_dx, dz_dy, dz_dxx, dz_dyy, dz_dxy);
end

