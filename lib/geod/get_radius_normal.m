function N = get_radius_normal (lat, ell)
%GET_RADIUS_NORMAL: Return the normal (i.e., along the prime vertical section) ellipsoidal radius of curvature, at a given geodetic latitude.

    a = ell.a;  b = ell.b;
    lat2 = lat .* (pi/180);
    N = a^2 ./ sqrt( a^2 .* (cos(lat2)).^2 + b^2 .* (sin(lat2)).^2 );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test block (see help test on GNU Octave).

%!shared
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! lat = rand(n, 1);

%!test
%! % When a = b (i.e., the the ellipsoid degenerates into a sphere),
%! % N = a everywhere.
%! ell.a = 1;  ell.b = ell.a;  ell.e = 0;
%! lat = 0:90:360;
%! N = get_radius_normal (lat, ell);
%! correct_answer = ell.a * ones(size(lat));
%! myassert (N, correct_answer, -sqrt(eps));

%!test
%! % At the equator:
%! lat = 0;
%! N = get_radius_normal(lat, ell);
%! correct_answer = ell.a;
%! myassert (N, correct_answer, -sqrt(eps));

%!test
%! % At the north pole:
%! lat = +90;
%! N = get_radius_normal(lat, ell);
%! correct_answer = ell.a^2 / ell.b;
%! myassert (N, correct_answer, -sqrt(eps));

%!test
%! % At the south pole:
%! lat = -90;
%! N = get_radius_normal(lat, ell);
%! correct_answer = ell.a^2 / ell.b;
%! myassert (N, correct_answer, -sqrt(eps));

