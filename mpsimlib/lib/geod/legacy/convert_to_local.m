% This is just an interface.
function sat_local = convert_to_local (rec_geod, sat_cart, ell)
    sat_local = convert_to_local_sph (...
        sat_cart, rec_geod, ell);
end

%!test
%! ell = get_ellipsoid_grs80;
%! base_geod = rand_pt_geod;
%! pt_cart = convert_to_cartesian(rand_pt_geod, ell);
%! 
%! myassert (...
%!     convert_to_local (base_geod, pt_cart, ell), ...
%!     convert_to_local_sph (pt_cart, base_geod, ell) );

