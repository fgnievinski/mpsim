function [rot, dir_nrml, slope, aspect] = get_rotation_matrix4_local (vec_zgrad_cart)
    vec_zgrad_cart = neu2xyz(vec_zgrad_cart);
    dz_dx = vec_zgrad_cart(:,1);
    dz_dy = vec_zgrad_cart(:,2);
    [slope, aspect, dir_nrml] = horizgrad2slopeaspect (dz_dx, dz_dy);
    %rot = get_rotation_matrix2_local([0 0 1], dir_nrml.cart);  % WRONG!
    rot = get_rotation_matrix5_local (dir_nrml);
end

