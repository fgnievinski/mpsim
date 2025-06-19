function M = get_radius_meridional (lat, ell)
%GET_RADIUS_MERIDIONAL: Return the meridional (i.e., along the meridian section) ellipsoidal radius of curvature, at a given geodetic latitude.

    a = ell.a;  e = ell.e;
    M = a * (1 - e.^2) ./ ( 1 - e.^2 .* (sin(lat.*pi./180)).^2 ).^(3/2);
end

%!shared
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! lat = rand(n, 1);

%!test
%! % When a = b (i.e., the ellipsoid degenerates into a sphere),
%! % M = a everywhere.
%! ell.a = 1;  ell.b = ell.a;  ell.e = 0;
%! lat = 0:10:360;
%! M = get_radius_meridional (lat, ell);
%! correct_answer = ell.a * ones(size(lat));
%! myassert (M, correct_answer, sqrt(eps));

%!test
%! % At the equator:
%! lat = 0;
%! M = get_radius_meridional(lat, ell);
%! correct_answer = ell.a * (1 - ell.e^2);
%! %[M,correct_answer,M-correct_answer]  % DEBUG
%! myassert (M, correct_answer, -sqrt(eps));

%!test
%! % At the north pole:
%! lat = +90;
%! M = get_radius_meridional(lat, ell);
%! correct_answer = ell.a^2 / ell.b;
%! myassert (M, correct_answer, -sqrt(eps));

%!test
%! % At the south pole:
%! lat = -90;
%! M = get_radius_meridional(lat, ell);
%! correct_answer = ell.a^2 / ell.b;
%! myassert (M, correct_answer, -sqrt(eps));

