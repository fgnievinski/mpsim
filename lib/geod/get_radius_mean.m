function R = get_radius_mean (lat, ell)
%GET_RADIUS_MEAN: Return the mean ellipsoidal radius of curvature, at a given geodetic latitude.

    M = get_radius_meridional (lat, ell);
    N = get_radius_normal     (lat, ell);
    m = 1./M;
    n = 1./N;
    r = (m+n)./2;
    R = 1./r;
end

