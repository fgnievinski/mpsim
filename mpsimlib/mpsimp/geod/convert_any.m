function [pt_out, optimized] = convert_any (pt_in, ...
coord_type_in, coord_type_out, ...
ell, base_geod, optimize)
%CONVERT_ANY: Convert from any type of coordinates to any other type of coordinates.

    if (nargin < 6) || isempty(optimize),  optimize = true;  end

    optimized = false;
    if optimize && strcmp(coord_type_out, coord_type_in)
        optimized = true;
        pt_out = pt_in;
        return;
    elseif optimize ...
        && strcmp(coord_type_out, 'local') ...
        && strcmp(coord_type_in,  'geod')  ...
        && isequal(pt_in, base_geod)
        optimized = true;
        pt_out = zeros(size(pt_in));
        return;
    elseif optimize ...
        && strcmp(coord_type_out, 'geod') ...
        && strcmp(coord_type_in,  'local')  ...
        && all(all(pt_in == 0))
        optimized = true;
        pt_out = base_geod;
        return;
    end

    pt_cart = convert_from_any (pt_in, ell, coord_type_in, base_geod);
    pt_out  = convert_to_any   (pt_cart, ell, coord_type_out, base_geod);
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
%! for j=1:length(coord_types)
%!     switch coord_types{i}
%!     case 'cart'
%!         pt_in = pt_cart;
%!     case 'local'
%!         pt_in = pt_local;
%!     case 'geodm'
%!         pt_in = pt_geodm;
%!     case 'geod'
%!         pt_in = pt_geod;
%!     end
%!     switch coord_types{j}
%!     case 'cart'
%!         pt_out = pt_cart;
%!     case 'local'
%!         pt_out = pt_local;
%!     case 'geodm'
%!         pt_out = pt_geodm;
%!     case 'geod'
%!         pt_out = pt_geod;
%!     end
%!     pt_out2 = convert_any (...
%!         pt_in, coord_types{i}, coord_types{j}, ell, base_geod);
%!     %coord_types{i}, coord_types{j}  % DEBUG
%!     %norm_all(pt_out2 - pt_out)  % DEBUG
%!     myassert (pt_out2, pt_out, -sqrt(eps));
%! end
%! end

%!test
%! % test optimization strcmp(coord_type_out, coord_type_in)
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! base_geod = rand_pt_geod(n);
%! pt_local = 100 * rand(n,3);
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%! pt_geod = convert_to_geodetic (pt_cart, ell);
%! pt_geodm = convert_to_geodm (pt_geod, ell);
%! 
%! % cputime_res applies to either t1 or t2 individually; 
%! % tol applies to t2-t1;
%! tol = 2*cputime_res + sqrt(eps);
%! 
%! coord_types = {'cart', 'local', 'geodm', 'geod'};
%! for i=1:length(coord_types)
%!     switch coord_types{i}
%!     case 'cart'
%!         pt_in = pt_cart;
%!     case 'local'
%!         pt_in = pt_local;
%!     case 'geodm'
%!         pt_in = pt_geodm;
%!     case 'geod'
%!         pt_in = pt_geod;
%!     end
%!     pt_out = pt_in;
%! 
%!     t = cputime;
%!     [pt_out2, optimized] = convert_any (...
%!         pt_in, coord_types{i}, coord_types{i}, ell, base_geod, false);
%!       t2 = cputime - t;
%!       myassert(optimized, false)
%!     t = cputime;
%!     [pt_out3, optimized] = convert_any (...
%!         pt_in, coord_types{i}, coord_types{i}, ell, base_geod, true);
%!       t3 = cputime - t;
%!       myassert(optimized, true)
%! 
%!     myassert (pt_out2, pt_out, -sqrt(eps));
%!     myassert (pt_out3, pt_out, -sqrt(eps));
%!     
%!     %[t3, t2+tol]
%!     myassert (t3 <= (t2 + tol));
%! end

%!test
%! % test optimization 
%! % && strcmp(coord_type_out, 'local') ...
%! % && strcmp(coord_type_in,  'geod')  ...
%! % && isequal(pt_in, base_geod)
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! base_geod = rand_pt_geod(n);
%! pt_geod = base_geod;
%! pt_local = zeros(size(pt_geod));
%! 
%! % cputime_res applies to either t1 or t2 individually; 
%! % tol applies to t2-t1;
%! tol = 2*cputime_res + sqrt(eps);
%! 
%! t = cputime;
%! [pt_local2, optimized] = convert_any (...
%!     pt_geod, 'geod', 'local', ell, base_geod, false);
%!   ta = cputime - t;
%!   myassert(optimized, false)
%!   myassert(pt_local2, pt_local, -sqrt(eps))
%! 
%! t = cputime;
%! [pt_local2, optimized] = convert_any (...
%!     pt_geod, 'geod', 'local', ell, base_geod, true);
%!   tb = cputime - t;
%!   myassert(optimized, true)
%!   myassert(pt_local2, pt_local, -sqrt(eps))
%! 
%! %[tb, ta+tol]
%! myassert (tb <= (tb + tol));

%!test
%! % test optimization 
%! % && strcmp(coord_type_out, 'geod') ...
%! % && strcmp(coord_type_in,  'local')  ...
%! % && all(all(pt_in == 0))
%! ell = get_ellipsoid('grs80');
%! n = ceil(10*rand);
%! base_geod = rand_pt_geod(n);
%! pt_geod = base_geod;
%! pt_local = zeros(size(pt_geod));
%! 
%! % cputime_res applies to either t1 or t2 individually; 
%! % tol applies to t2-t1;
%! tol = 2*cputime_res + sqrt(eps);
%! 
%! t = cputime;
%! [pt_geod2, optimized] = convert_any (...
%!     pt_local, 'local', 'geod', ell, base_geod, false);
%!   ta = cputime - t;
%!   myassert(optimized, false)
%!   myassert(pt_geod2, pt_geod, -sqrt(eps))
%! 
%! t = cputime;
%! [pt_geod2, optimized] = convert_any (...
%!     pt_local, 'local', 'geod', ell, base_geod, true);
%!   tb = cputime - t;
%!   myassert(optimized, true)
%!   myassert(pt_geod2, pt_geod, -sqrt(eps))
%! 
%! %[tb, ta+tol]
%! myassert (tb <= (tb + tol));
