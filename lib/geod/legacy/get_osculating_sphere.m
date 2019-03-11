function [pos_cart0, R] = get_osculating_sphere (pos_geod, ell)
    [pos_cart0, R] = get_sphere_osculating (pos_geod, ell);
end

