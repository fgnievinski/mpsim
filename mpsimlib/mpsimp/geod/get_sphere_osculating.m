function [pos_cart0, R] = get_sphere_osculating (pos_geod, ell)
%GET_SPHERE_OSCULATING: Return the center (in global Cartesian coordinates) of an osculating sphere, i.e., normal to the ellipsod at a given point (in geodetic coordinates) and having radius equal to the Gaussian radius.

    R = get_radius_gaussian (pos_geod(1), ell);
    pos_cart0 = get_sphere_normal (pos_geod, ell, R);
end

