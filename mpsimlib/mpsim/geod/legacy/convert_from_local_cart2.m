% This is just an interface.
function varargout = convert_from_local_cart2 (pt_local, base_geod, ell)
    [varargout{1:nargout}] = convert_from_local_cart (pt_local, base_geod, ell);
end

%!test
%! n = round(10*rand);
%! pt_local = rand(n,3);
%! base_geod = rand_pt_geod;
%! ell = get_ellipsoid('grs80');
%! 
%! pt_cart  = convert_from_local_cart (pt_local, base_geod, ell);
%! pt_cart2 = convert_from_local_cart2 (pt_local, base_geod, ell);
%! [pt_cart2, pt_geod2] = convert_from_local_cart2 (pt_local, base_geod, ell);
%! 
%! myassert(pt_cart2, pt_cart)

