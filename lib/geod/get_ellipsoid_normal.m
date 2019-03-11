function dir = get_ellipsoid_normal (pos_geod, ~)
%GET_ELLIPSOID_NORMAL: Return ellipsoidal normal direction (in global Cartesian coordinates), at given geodetic position.

    lat = pos_geod(:,1);
    lon = pos_geod(:,2);

    dir = zeros(size(pos_geod));
    dir(:,1) = cos(lat*pi/180) .* cos(lon*pi/180);
    dir(:,2) = cos(lat*pi/180) .* sin(lon*pi/180);
    dir(:,3) = sin(lat*pi/180);
    % dir is in global cartesian coordinates.
end

%!test
%! ell = get_ellipsoid('grs80');
%! n = round(10*rand);
%! pos_geod = rand_pos_geod(n);
%! dir = get_ellipsoid_normal (pos_geod, ell);
%! temp = repmat([0 0 1], [n 1]);
%! dir2 = convert_from_local_cart (temp, pos_geod, ell, true);
%! myassert(norm_all(dir), ones(n,1), -sqrt(eps))
%! myassert(dir, dir2, -sqrt(eps))



