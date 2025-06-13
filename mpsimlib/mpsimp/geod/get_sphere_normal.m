function pos_cart0 = get_sphere_normal (pos_geod, ell, R)
%GET_SPHERE_NORMAL: Return the center (in global Cartesian coordinates) of a sphere normal to the ellipsod, at a given point (in geodetic coordinates) and having a given radius.

    myassert(size(pos_geod,1) == 1);
    temp = zeros(length(R),3);
    temp(:,3) = -R;
    pos_cart0 = convert_from_local_cart (temp, [pos_geod(1:2), 0], ell);
end

