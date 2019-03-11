function J = get_jacobian_cart2any (pt, ell, coord_type, base_geod)
%GET_JACOBIAN_CART2ANY: Return the Jacobian matrix of any coordinate type w.r.t. global Cartesian coordinates.

    switch coord_type
    case 'cart'
        %pt_cart = pt;
        J = repmat(eye(3), [1,1,size(pt,1)]);
    case 'local'
        %pt_local = pt;
        J = get_jacobian_cart2local (base_geod, ell);
    case 'geodm'
        pt_geodm = pt;
        pt_geod = convert_from_geodm (pt_geodm, ell);
        J = get_jacobian_cart2geodm (pt_geod, ell);
    case 'geod'
        pt_geod = pt;
        J = get_jacobian_cart2geod (pt_geod, ell);
    end
end

%!test
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod;
%! pt_local = rand(1,3) * 100;
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%! pt_geod = convert_to_geodetic (pt_cart, ell);
%! pt_geodm = convert_to_geodm (pt_geod, ell);
%! 
%! coord_types = {'cart', 'local', 'geodm', 'geod'};
%! for i=1:length(coord_types)
%!     %coord_types{i}  % DEBUG
%!     switch coord_types{i}
%!     case 'cart'
%!         pt = pt_cart;
%!     case 'local'
%!         pt = pt_local;
%!     case 'geodm'
%!         pt = pt_geodm;
%!     case 'geod'
%!         pt = pt_geod;
%!     end
%! 
%!     J = diff_func_obs (@(pt) ...
%!         convert_to_any (pt, ell, coord_types{i}, base_geod), ...
%!         pt_cart);
%!     J2 = get_jacobian_cart2any (pt, ell, coord_types{i}, base_geod);
%!     
%!     Je = J - J2;
%!     %J, J2, Je, max(abs(Je(:)))  % DEBUG
%!     myassert (J2, J, -1e-3);
%! end

