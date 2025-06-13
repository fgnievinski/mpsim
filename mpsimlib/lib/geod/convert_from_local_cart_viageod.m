function [pt_geod, pt_cart] = convert_from_local_cart_viageod (pt_local, base_geod, ell)
%CONVERT_FROM_LOCAL_CART_VIAGEOD: Convert from local Cartesian coordinates, to geodetic curvilinear coordinates, and then (optionally, non-orthogonally) to global Cartesian coordinates.

    num_pts   = size(pt_local, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_bases == num_pts);
    if (num_bases == 1),  base_geod = repmat(base_geod, num_pts, 1);  end
    
    k = k_diff_metric (base_geod, ell);
    diff_geod = pt_local ./ k;
    pt_geod = base_geod + diff_geod;

    if (nargout > 1)
        pt_cart = convert_to_cartesian (pt_geod, ell);
    end
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
%! pt_geod2 = convert_from_local_cart_viageod (pt_local, base_geod, ell);
%! diff_geod2 = pt_geod2 - base_geod;
%! 
%! %[diff_geod2 - diff_geod]
%! myassert (diff_geod2, diff_geod, -sqrt(eps));

%!test
%! % differences in height should remain unchanged:
%! pt_local = [zeros(n,1), zeros(n,1), rand(n,1)];
%! diff_geod = pt_local;
%! pt_geod = base_geod + diff_geod;
%! 
%! pt_geod2 = convert_from_local_cart_viageod (pt_local, base_geod, ell);
%! diff_geod2 = pt_geod2 - base_geod;
%! 
%! %[diff_geod2 - diff_geod]
%! myassert (diff_geod2, diff_geod, -sqrt(eps));

%!test
%! % make sure that forward and inverse are consistent:
%! pt_local = rand(n,3);
%! pt_local2 = ...
%!     convert_to_local_cart_viageod (...
%!     convert_from_local_cart_viageod (pt_local, base_geod, ell), ...
%!     base_geod, ell);
%! %[pt_local2 - pt_local]
%! myassert (pt_local2, pt_local, -sqrt(eps));

%!test
%! % second, optional, output argument:
%! pt_local = rand(n,3);
%! [pt_geod, pt_cart] = convert_from_local_cart_viageod (pt_local, base_geod, ell);
%! myassert (size(pt_cart), size(pt_geod));

%!test
%! % The conversion between global cartesian coordinates 
%! % and local cartesian coordinates may be defined in 
%! % two different ways:
%! %     (i) converting first to geodetic coordinates;
%! %     (ii) converting directly to global cartesian coordinates.
%! % Functions convert_{to/from}_local_cart_viageod follow (i);
%! % functions convert_{from/to}_local_cart follow (ii);
%! % 
%! % Results from (i) and (ii) are generally different, 
%! % except for small values for the local coordinates.
%! % That is because (ii) is a linear approximation for (i).
%! %
%! % Only (ii) preserves length of the position vector w.r.t. 
%! % base position.
%! base_cart = convert_to_cartesian(base_geod, ell);
%! pt_local = 1e3*rand(n,3);
%! 
%! [temp, pt_cart1] = convert_from_local_cart_viageod(pt_local, base_geod, ell);
%!        pt_cart2  = convert_from_local_cart(pt_local, base_geod, ell);
%! diff_cart1 = pt_cart1 - base_cart;
%! diff_cart2 = pt_cart2 - base_cart;
%! 
%! %norm_all(diff_cart1)-norm_all(pt_local)
%! %norm_all(diff_cart2)-norm_all(pt_local)
%! myassert( abs(norm_all(diff_cart2)-norm_all(pt_local)) < sqrt(eps) )
%! myassert( abs(norm_all(diff_cart2)-norm_all(pt_local)) < ...
%!         abs(norm_all(diff_cart1)-norm_all(pt_local)) )

