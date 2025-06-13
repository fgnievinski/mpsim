function [pt_local_sph, pt_local_cart, J] = convert_to_local_sph (...
pt_cart, base_geod, ell, is_input_velocity)
%CONVERT_TO_LOCAL_SPH: Convert to local spherical coordinates, given global Cartesian coordinates; local Cartesian coordinates are available as a by-product.

    if (nargin < 4),  is_input_velocity = [];  end
    [pt_local_cart, J] = convert_to_local_cart (pt_cart, base_geod, ell, is_input_velocity);
    pt_local_sph = convert_local_cart2sph (pt_local_cart);
end

%!shared
%! n = ceil(10*rand);
%! ell = get_ellipsoid('grs80');
%! %ell.a=1; ell.b=1;  ell.e=0;
%! pt_cart = convert_to_cartesian (rand_pt_geod(n), ell);
%! base_geod = rand_pt_geod;

%!test
%! % multiple bases:
%! pt_local  = convert_to_local_sph (pt_cart, repmat(base_geod, n, 1), ell);
%! pt_local2 = convert_to_local_sph (pt_cart, base_geod, ell);
%! myassert (pt_local, pt_local2);

%!test
%! % length should not change from global cartesian to local cartesian coord:
%! temp = convert_to_local_sph (pt_cart, base_geod, ell);
%! norm = temp(:,3);
%! base_cart = convert_to_cartesian (base_geod, ell);
%! norm2 = norm_all(pt_cart - repmat(base_cart, n, 1));
%! %[norm - norm2]  % DEBUG
%! myassert (norm, norm2, -sqrt(eps))

%!test
%! % Consistency check between convert_{from/to}_local_sph().
%! pt_local = convert_to_local_sph (pt_cart, base_geod, ell);
%! pt_cart2 = convert_from_local_sph (pt_local, base_geod, ell);
%! %pt_cart2, pt_cart  % DEBUG
%! %[pt_cart2 - pt_cart]  % DEBUG
%! myassert (pt_cart2, pt_cart, -sqrt(eps))


%%%%%%%%%%%%%%%%%%%%%%
% Test elevation angle

%!test
%! % direction up
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [0 0 1];
%! pt_local = [90 NaN 1];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % don't compare azimuth because it can assume any value at zenith:
%! myassert (answer(1), pt_local(1), -100*eps);

%!test
%! % direction down
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart - [0 0 1];
%! pt_local = [-90 NaN 1];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % don't compare elev ang because it can assume any value at zenith:
%! myassert (answer(1), pt_local(1), -100*eps);

%!test
%! % elevation +45deg
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [1 0 1];
%! pt_local = [+45 NaN NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_local(1), -100*eps);

%!test
%! % elevation -45deg
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart - [1 0 1];
%! pt_local = [-45 NaN NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_local(1), -100*eps);

%!test
%! % elevation +45deg, at a different azimuth
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart + [0 1 1];
%! pt_local = [+45 NaN NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_local(1), -100*eps);

%!test
%! % elevation -45deg, at a different azimuth
%! base_geod = [90 0 0];
%! base_cart = convert_to_cartesian (base_geod, ell);
%! pt_cart = base_cart - [0 1 1];
%! pt_local = [-45 NaN NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only elev ang because other components are complicated:
%! myassert (answer(1), pt_local(1), -100*eps);


%%%%%%%%%%%%%%%%%%%%%%
% Test azimuth

%!test
%! % direction north
%! base_geod = [0 0 0];
%! pt_geod = [15 0 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [NaN 0 NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_local(2), -100*eps);

%!test
%! % direction south
%! base_geod = [0 0 0];
%! pt_geod = [-15 0 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [NaN 180 NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_local(2), -100*eps);

%!test
%! % direction east
%! base_geod = [0 0 0];
%! pt_geod = [0 15 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [NaN 90 NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_local(2), -100*eps);

%!test
%! % direction west
%! base_geod = [0 0 0];
%! pt_geod = [0 -15 0];
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! pt_local = [NaN -90 NaN];
%! 
%! answer = convert_to_local_sph (pt_cart, base_geod, ell);
%! 
%! % compare only azimuth because other components are complicated:
%! myassert (answer(2), pt_local(2), -100*eps);

