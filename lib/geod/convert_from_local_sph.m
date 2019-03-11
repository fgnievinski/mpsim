function [pt_global_cart, pt_local_cart] = convert_from_local_sph (...
pt_local_sph, base_geod, ell, is_input_velocity)
%CONVERT_FROM_LOCAL_SPH: Convert from local spherical coordinates, to global Cartesian coordinates; local Cartesian coordinates are available as a by-product.

    if (nargin < 4),  is_input_velocity = [];  end
    pt_local_cart = convert_local_sph2cart (pt_local_sph);    
    pt_global_cart = convert_from_local_cart (...
        pt_local_cart, base_geod, ell, is_input_velocity);
end

%!shared
%! n = ceil(10*rand);
%! ell = get_ellipsoid('grs80');
%! pt_local = [rand(n,1)*90, rand(n,1)*360, 1000*rand(n,1)];
%! base_geod = rand_pt_geod;

%!test
%! % multiple bases:
%! pt_cart  = convert_from_local_sph (pt_local, repmat(base_geod, n, 1), ell);
%! pt_cart2 = convert_from_local_sph (pt_local, base_geod, ell);
%! myassert (pt_cart, pt_cart2);

%!test
%! % length should not change from global cartesian to local cartesian coord:
%! norm = pt_local(:,3);
%! pt_cart = convert_from_local_sph (pt_local, base_geod, ell);
%! base_cart = convert_to_cartesian (base_geod, ell);
%! norm2 = norm_all(pt_cart - repmat(base_cart, n, 1));
%! %[norm - norm2]  % DEBUG
%! myassert (norm, norm2, -sqrt(eps))

%!test
%! % Consistency check between convert_{from/to}_local_sph().
%! pt_cart = convert_from_local_sph (pt_local, base_geod, ell);
%! pt_local2 = convert_to_local_sph (pt_cart, base_geod, ell);
%! pt_local2(:,2) = mod(pt_local2(:,2), 360);
%! %pt_local2, pt_local  % DEBUG
%! %[pt_local2 - pt_local]  % DEBUG
%! myassert (pt_local2, pt_local, -nthroot(eps, 3))


%%%%%%%%%%%%%%%%%%%%%%
% Test elevation angle

%!test
%! % direction up
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [0 0 1];
%! pt_local = [90 0 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % don't compare azimuth because it can assume any value at zenith:
%! myassert (answer(1), pt_cart(1), -100*eps);

%!test
%! % direction down
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart - [0 0 1];
%! pt_local = [-90 0 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % don't compare elev ang because it can assume any value at zenith:
%! myassert (answer(1), pt_cart(1), -100*eps);

%!test
%! % elevation +45deg
%! base_geod = [0 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [1 0 1]/norm([1 0 1]);
%! pt_local = [+45 0 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_cart(1), -100*eps);

%!test
%! % elevation -45deg
%! base_geod = [0 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart - [1 0 1]/norm([1 0 1]);
%! pt_local = [-45 0 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_cart(1), -100*eps);

%!test
%! % elevation +45deg, at a different azimuth
%! base_geod = [0 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [1 1 0]/norm([0 1 1]);
%! pt_local = [+45 90 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_cart(1), -100*eps);

%!test
%! % elevation -45deg, at a different azimuth
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [-1 1 0]/[1 1 0];
%! pt_local = [-45 90 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_cart(1), -100*eps);


%%%%%%%%%%%%%%%%%%%%%%
% Test azimuth

%!test
%! % direction north
%! base_geod = [0 0 0];
%! pt_geod = [15 0 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [0 0 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_cart(2), -100*eps);

%!test
%! % direction south
%! base_geod = [0 0 0];
%! pt_geod = [-15 0 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [0 180 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_cart(2), -100*eps);

%!test
%! % direction east
%! base_geod = [0 0 0];
%! pt_local = [0 90 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2) > 0);

%!test
%! % direction west
%! base_geod = [0 0 0];
%! pt_local = [0 -90 1];
%! 
%! answer = convert_from_local_sph (pt_local, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2) <  0);

