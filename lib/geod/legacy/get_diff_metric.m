function answer = get_diff_metric (diff_geod, base_geod, ell)
    num_pts   = size(diff_geod, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_bases == num_pts);
    if (num_bases == 1)    
        base_geod = repmat(base_geod, num_pts, 1);
    end
    
    answer = get_diff_metric_remote (base_geod + diff_geod, base_geod, ell);
end

%!shared
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod;

%!test
%! pt_geod = rand_pt_geod;
%! diff_geod = pt_geod - base_geod;
%! 
%! myassert (...
%!     get_diff_metric (diff_geod, base_geod, ell), ...
%!     convert_to_local_cart_viageod (pt_geod, base_geod, ell), ...
%!     -sqrt(eps));

%!test
%! pt_local = 1000 * rand(1,3);
%! pt_local2 = ...
%! get_diff_metric (inv_diff_metric (pt_local, base_geod, ell), base_geod, ell);
%! %pt_local2 - pt_local
%! myassert(pt_local2, pt_local, -sqrt(eps))

