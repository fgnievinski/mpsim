function J = get_jacobian_local2any (pt_local, ell, coord_type, base_geod)
%GET_JACOBIAN_LOCAL2ANY: Return the Jacobian matrix of any coordinate type w.r.t. local Cartesian coordinates.

    switch coord_type
    case 'cart'
        J = get_jacobian_local2cart (base_geod, ell);
    case 'local'
        J = repmat(diag([1 1 1]), [1,1,size(pt_local,1)]);
    case 'geodm'
        J = get_jacobian_local2geodm (pt_local, base_geod, ell);
    case 'geod'
        J = get_jacobian_local2geod (pt_local, base_geod, ell);
    end
end

%!test
%! ell = get_ellipsoid('fake');
%! n = ceil(10*rand);
%! base_geod = rand_pt_geod(n);
%! pt_local = 1000*rand(n,3);
%! 
%! function pt_any = convert_from_local_to_any (...
%! pt_local, ell, coord_type, base_geod)
%!     pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%!     pt_any = convert_to_any (pt_cart, ell, coord_type, base_geod);
%! end
%! 
%! %coord_types = {'cart', 'local', 'geodm', 'geod'};
%! coord_types = {'cart', 'local', 'geod'};
%! for i=1:length(coord_types)
%!     f = @(pt_local_) convert_from_local_to_any (pt_local_, ell, coord_types{i}, base_geod);
%!     %coord_types{i}  % DEBUG
%!     J = diff_func_obs (f, pt_local);
%!     J2 = get_jacobian_local2any (pt_local, ell, coord_types{i}, base_geod);
%!     
%!     Je = J - J2;
%!     %coord_types{i}, J, J2, Je, max(abs(Je(:)))
%!     myassert (J2, J, -1e-3);
%! end

