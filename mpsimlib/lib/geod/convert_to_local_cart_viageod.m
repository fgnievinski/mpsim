function pt_local = convert_to_local_cart_viageod (pt_geod, base_geod, ell)
%CONVERT_TO_LOCAL_CART_VIAGEOD: Convert to local Cartesian coordinates, given geodetic curvilinear coordinates.

    if (nargin < 3) || isempty(ell),  ell = get_ellipsoid();  end
    num_pts   = size(pt_geod, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_pts == 1 || num_bases == num_pts);
    if (num_bases == 1),  base_geod = repmat(base_geod, num_pts,   1);  end
    if (num_pts   == 1),    pt_geod = repmat(  pt_geod, num_bases, 1);  end
    k = k_diff_metric (base_geod, ell);
    diff_geod = pt_geod - base_geod;
    pt_local = k .* diff_geod;
end

%!shared
%! n = ceil (10*rand);
%! base_geod = rand_pt_geod (n);
%! ell = get_ellipsoid('grs80');

%!test
%! % diff in longitude for points on the Equator and height zero is simple:
%! base_geod(:, 1) = 0;  base_geod(:, 3) = 0;
%! pt_local = [zeros(n,1), rand(n,1), zeros(n,1)];
%! diff_geod = [zeros(n,1), pt_local(:,2)/ell.a*180/pi, zeros(n,1)];
%! pt_geod = base_geod + diff_geod;
%! 
%! pt_local2 = convert_to_local_cart_viageod (pt_geod, base_geod, ell);
%! 
%! %[pt_local2 - pt_local]
%! myassert (pt_local2, pt_local, -sqrt(eps));

%!test
%! % differences in height should remain unchanged:
%! pt_local = [zeros(n,1), zeros(n,1), rand(n,1)];
%! diff_geod = pt_local;
%! pt_geod = base_geod + diff_geod;
%! 
%! pt_local2 = convert_to_local_cart_viageod (pt_geod, base_geod, ell);
%! 
%! %[pt_local2 - pt_local]
%! myassert (pt_local2, pt_local, -sqrt(eps));

%!test
%! % make sure that forward and inverse are consistent:
%! pt_local = rand(n,3);
%! pt_local2 = ...
%!     convert_to_local_cart_viageod (...
%!     convert_from_local_cart_viageod (pt_local, base_geod, ell), ...
%!     base_geod, ell);
%! %[pt_local2 - pt_local]
%! myassert (pt_local2, pt_local, -sqrt(eps));

