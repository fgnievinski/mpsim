function answer = get_diff_metric_remote (remote, base, ell)
    answer = convert_to_local_cart_viageod (remote, base, ell);
end

%!test
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod;
%! pt_geod = rand_pt_geod;
%! 
%! myassert (...
%!     get_diff_metric_remote (pt_geod, base_geod, ell), ...
%!     convert_to_local_cart_viageod (pt_geod, base_geod, ell) );

