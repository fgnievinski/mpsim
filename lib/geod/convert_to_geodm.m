function pt_geodm = convert_to_geodm (pt_geod, ell)
%CONVERT_TO_GEODM: Convert to ellipsoidal arc-lengths (at non-zero height), given geodetic coordinates.

    lat = pt_geod(:,1);
    lon = pt_geod(:,2);
      h = pt_geod(:,3);

    latm = convert_to_latm (lat, h, ell);
    N = compute_prime_vertical_radius (lat, ell);
    lonm = (N + h) .* cos(lat*pi/180) .* (lon*pi/180 - 0);

    pt_geodm = [latm, lonm, h];
end

%!shared
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! pt_geod = rand_pt_geod (n);

%!test
%! pt_geod = [0, 0, 0];
%! pt_geodm = convert_to_geodm (pt_geod, ell);
%! myassert (pt_geodm, [0, 0, 0]);

%!test
%! % when ellipsoid degenerates onto a sphere,
%! % expressions greatly simplify.
%! ell.b = ell.a;  ell.e = 0;  ell.f = 0;
%! 
%! lat = pt_geod(:,1);
%! lon = pt_geod(:,2);
%!   h = pt_geod(:,3);
%! 
%! R = ell.a;
%! latm = (R + h)                    .* lat*pi/180;
%! lonm = (R + h) .* cos(lat*pi/180) .* lon*pi/180;
%! pt_geodm = [latm, lonm, h];
%! 
%! pt_geodm2 = convert_to_geodm (pt_geod, ell);
%! 
%! %max(abs(pt_geodm2 - pt_geodm))
%! myassert (pt_geodm2, pt_geodm, -10*sqrt(eps));

