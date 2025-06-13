function [dir_nrml, rot] = alongacross2sfcnrml (along, across, azim)
    rot_azim = get_rotation_matrix_local(3, azim);
    rot_along = get_rotation_matrix_local(1, -along);
    rot_across = get_rotation_matrix_local(2, -across);
    rot = frontal_mtimes2(rot_azim, rot_across, rot_along);
    up_dir = [0 0 1];
    dir_nrml = struct();
    dir_nrml.cart = frontal_mtimes_pt(rot, up_dir);
    dir_nrml.sph = cart2sph_local(dir_nrml.cart);
    dir_nrml.elev = dir_nrml.sph(:,1);
    dir_nrml.azim = dir_nrml.sph(:,2);
end
