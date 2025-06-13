% This is just an interface.
function pt_local = convert_to_local_cart2 (pt_cart, base_geod, ell)
    pt_local = convert_to_local_cart (pt_cart, base_geod, ell);
end

%!test
%! n = round(10*rand);
%! pt_cart = rand(n,3);
%! base_geod = rand_pt_geod;
%! ell = get_ellipsoid('grs80');
%! 
%! pt_local  = convert_to_local_cart (pt_cart, base_geod, ell);
%! pt_local2 = convert_to_local_cart2 (pt_cart, base_geod, ell);
%! 
%! myassert(pt_local2, pt_local)

