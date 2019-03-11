function [pt_local, J] = convert_to_local_cart (pt_cart, base_geod, ell, is_input_velocity_or_relative)
%CONVERT_TO_LOCAL_CART: Convert to local Cartesian coordinates, given global Cartesian coordinates.

    if (nargin < 3) || isempty(ell),  ell = get_ellipsoid();  end
    if (nargin < 4) || isempty(is_input_velocity_or_relative),  is_input_velocity_or_relative = false;  end
    if isempty(pt_cart)
        pt_local = zeros(size(pt_cart));
        return;
    end
    if (nargin < 3)
        % spherical case; base_geod is actually base_sph; 
        % results do not depend on specific sphere radius employed.
        ell = get_ellipsoid('sphere');
        base_geod(:,3) = base_geod(:,3) - ell.a;
    end

    num_pts   = size(pt_cart, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_pts == 1 || num_bases == num_pts);

    if is_input_velocity_or_relative
        diff_cart = pt_cart;
    else
        base_cart = convert_to_cartesian (base_geod, ell);
        diff_cart = minus_all(pt_cart, base_cart);
    end    
    
    if nnz(diff_cart) == 0
        pt_local = diff_cart;
        if (nargout > 1),  J = get_jacobian_cart2local (base_geod, ell);  end
        return;
    end

    J = get_jacobian_cart2local (base_geod, ell);

    J = frontal(J);  diff_cart = frontal(diff_cart, 'pt');
    pt_local = (J * diff_cart')';
    pt_local = defrontal(pt_local, 'pt');
    %diff_cart = frontal_pt(diff_cart);
    %pt_local = frontal_transpose(...
    %    frontal_mtimes(J, frontal_transpose(diff_cart)));
    %pt_local = defrontal_pt(pt_local);
    %%pt_local = zeros(num_pts, 3);
    %%for k=1:num_pts
    %%    pt_local(k,:) = (J(:,:,k) * diff_cart(k,:)')';
    %%end
    
    if (nargout > 1),  J = defrontal(J);  end
end

%!shared
%! n = ceil (10*rand);
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (n);
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_local = rand(n, 3);
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%! diff_cart = pt_cart - base_cart;

%!test
%! % length is preserved in this conversion:
%! pt_local = convert_to_local_cart (pt_cart, base_geod, ell);
%! %[norm_all(pt_local), norm_all(diff_cart)]
%! myassert(norm_all (pt_local), norm_all (diff_cart), -sqrt(eps));

%!test
%! % make sure that forward and inverse are consistent:
%! pt_local2 = ...
%!     convert_to_local_cart (...
%!     convert_from_local_cart (pt_local, base_geod, ell), ...
%!     base_geod, ell);
%! %[pt_local2 - pt_local]
%! myassert (pt_local2, pt_local, -sqrt(eps));

%!test
%! % Compare different implementations:
%! pt_local  = convert_to_local_cart  (pt_cart, base_geod, ell);
%! pt_localb = convert_to_local_cartb (pt_cart, base_geod, ell);
%! 
%! %pt_local - pt_localb  % DEBUG
%! myassert (pt_local, pt_localb, -sqrt(eps));
%!
%! function pt_local = convert_to_local_cartb (pt_cart, base_geod, ell)
%!     % Formulas from:
%!     % Hofmann-Wellenhof et al. GPS -- Theory and Practice. 2001. 
%!     % Fifth edition, pages 282-284.
%! 
%!     num_pts   = size(pt_cart,  1);
%!     num_bases = size(base_geod, 1);
%!     myassert (num_bases == 1 || num_bases == num_pts);
%!     if (num_bases == 1)
%!         base_geod = repmat(base_geod, num_pts, 1);
%!     end
%!    
%!     base_lat_rad = base_geod(:,1)*pi/180;  
%!     base_lon_rad = base_geod(:,2)*pi/180;
%! 
%!     %%%%%
%!     % Axis of local (tangent plane) coordinate system at base,
%!     % expressed in global cartesian coordinates:
%!     north_dir = [...
%!         -sin(base_lat_rad) .* cos(base_lon_rad), ...
%!         -sin(base_lat_rad) .* sin(base_lon_rad), ...
%!          cos(base_lat_rad)];
%!     east_dir  = [...
%!         -sin(base_lon_rad), ...
%!          cos(base_lon_rad), ...
%!          zeros(num_pts,1)];
%!     up_dir    = [...
%!          cos(base_lat_rad) .* cos(base_lon_rad), ...
%!          cos(base_lat_rad) .* sin(base_lon_rad), ...
%!          sin(base_lat_rad)];
%!     % directions should be mutually perpendicular:
%!     zeros_n = zeros(num_pts,1);
%!     myassert(dot_all(north_dir, east_dir), zeros_n, -eps);
%!     myassert(dot_all(north_dir, up_dir), zeros_n, -eps);
%!     myassert(dot_all(east_dir, up_dir), zeros_n, -eps );
%!     
%!     pt_local = zeros(num_pts, 3);
%!     base_cart = convert_to_cartesian (base_geod, ell);
%!     dir_base_to_pt_cart = pt_cart - base_cart;
%!     
%!     %%%%%
%!     % Local cartesian coordinates:
%!     pt_north = dot_all(north_dir, dir_base_to_pt_cart);
%!     pt_east  = dot_all(east_dir, dir_base_to_pt_cart);
%!     pt_up    = dot_all(up_dir, dir_base_to_pt_cart);
%! 
%!     pt_local = [pt_north, pt_east, pt_up];
%! end

%!test
%! % empty in, empty out.
%! myassert(isempty(convert_to_local_cart([])));

