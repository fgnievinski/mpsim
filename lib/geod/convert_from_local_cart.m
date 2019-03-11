function [pt_cart, pt_geod] = convert_from_local_cart (...
pt_local, base_geod, ell, is_input_velocity)
%CONVERT_FROM_LOCAL_CART: Convert from local Cartesian coordinates, to global Cartesian coordinates (orthogonally), and then (optionally) to geodetic curvilinear coordinates.

    if (nargin < 4) || isempty(is_input_velocity),  is_input_velocity = false;  end
    num_pts   = size(pt_local, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_pts == 1 || num_bases == num_pts);
    if (num_bases == 1),  base_geod = repmat(base_geod, num_pts, 1);  end
    if (num_pts   == 1),  pt_local  = repmat(pt_local,  num_bases, 1);  end

    if (nnz(pt_local) == 0)
        pt_geod = base_geod;
        pt_cart = convert_to_cartesian (pt_geod, ell);
        return;
    end

    J = get_jacobian_local2cart (base_geod, ell);

    J = frontal(J);  pt_local = frontal(pt_local, 'pt');
    diff_cart = (J * pt_local')';
    diff_cart = defrontal(diff_cart, 'pt');
    %pt_local = frontal_pt(pt_local);
    %diff_cart = frontal_transpose(...
    %    frontal_mtimes(J, frontal_transpose(pt_local)));
    %diff_cart = defrontal_pt(diff_cart);
    %%diff_cart = zeros(num_pts, 3);
    %%for k=1:num_pts
    %%    diff_cart(k,:) = (J(:,:,k) * pt_local(k,:)')';
    %%end

    if is_input_velocity
        pt_cart = diff_cart;
        return;
    end
    
    base_cart = convert_to_cartesian (base_geod, ell);
    pt_cart = base_cart + diff_cart;

    if (nargout > 1)
        pt_geod = convert_to_geodetic (pt_cart, ell);
    end
end

%!shared
%! n = ceil (10*rand);
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (n);
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_local = rand(n, 3);

%!test
%! % length is preserved in this conversion:
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%! diff_cart = pt_cart - base_cart;
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
%! % second, optional, output argument:
%! [pt_cart, pt_geod] = convert_from_local_cart (pt_local, base_geod, ell);
%! myassert (size(pt_geod), size(pt_cart));

