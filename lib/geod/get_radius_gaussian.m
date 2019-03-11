function R = get_radius_gaussian (lat, ell)
%GET_RADIUS_GAUSSIAN: Return the Gaussian (i.e., intrinsic) ellipsoidal radius of curvature, at a given geodetic latitude.

    M = get_radius_meridional (lat, ell);
    N = get_radius_normal     (lat, ell);
    R = sqrt(M.*N);
end

