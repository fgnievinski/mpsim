function [slope, aspect, dir_nrml] = sfcnrml2slopeaspect (dir_nrml)
    if ~isstruct(dir_nrml)
        dir_nrml_cart = dir_nrml;
        dir_nrml = struct();
        dir_nrml.cart = dir_nrml_cart;
        dir_nrml.sph = cart2sph_local(dir_nrml.cart);
        dir_nrml.elev = dir_nrml.sph(:,1);
        dir_nrml.azim = dir_nrml.sph(:,2);
    end
    slope  = 90 - dir_nrml.elev;
    aspect = dir_nrml.azim;
    aspect = azimuth_range_positive(aspect);
end
