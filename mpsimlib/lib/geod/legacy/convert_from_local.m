% This is just an interface.
function sat_cart = convert_from_local (rec_geod, sat_local, ell)
    sat_cart = convert_from_local_sph (...
        sat_local, rec_geod, ell);
end

%!test
%! ell = get_ellipsoid_grs80;
%! base_geod = rand_pt_geod;
%! pt_local = rand(1,3);
%! 
%! myassert (...
%!     convert_from_local (base_geod, pt_local, ell), ...
%!     convert_from_local_sph (pt_local, base_geod, ell) );

