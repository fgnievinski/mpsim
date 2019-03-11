function pt_geod = convert_from_geodm (pt_geodm, ell)
%CONVERT_FROM_GEODM: Convert from ellipsoidal arc-lengths (at non-zero height), to geodetic coordinates.

    % cache for repeated calls with the same arguments:
    persistent pt_geodm2 ell2 pt_geod2
    myassert (isequal(size(pt_geod2), size(pt_geodm2)));
    if    ~isempty(pt_geod2) ...
       && isequal(ell, ell2) ...
       && isequaln(pt_geodm, pt_geodm2)
        pt_geod = pt_geod2;
        return;
    end
    if isempty(ell2) || isempty(pt_geodm2)
        pt_geodm2 = pt_geodm;
        ell2 = ell;
    end

    latm = pt_geodm (:,1);
    lonm = pt_geodm (:,2);
    h    = pt_geodm (:,3);
    n = size(pt_geodm, 1);

    % invert latm iteratively:
    lat0 = 180/pi * latm / ell.a;  % initial approximation (exact for sphere)
    lat = zeros(n,1);
    opt = struct('tolx',eps());  % octave's default may be different.
    for i=1:n
        % have to redefine function f because of h(i) and latm(i).
        f = @(lat) convert_to_latm (lat, h(i), ell) - latm(i);
        [lat(i), fval, exit_flag, output] = fzero (f, lat0(i), opt);
    end

    % 
    N = compute_prime_vertical_radius (lat, ell);
    lon = 180/pi * lonm ./ ( (N + h) .* cos(lat*pi/180) );

    %
    pt_geod = [lat, lon, h];

    % update cache:
    pt_geodm2 = pt_geodm;
    ell2 = ell;
    pt_geod2 = pt_geod;
end

%!shared
%! n = ceil(10*rand);
%! pt_geod = rand_pt_geod (n);
%! ell = get_ellipsoid('grs80');
%! pt_geodm = convert_to_geodm (pt_geod, ell);

%!test
%! pt_geod2 = convert_from_geodm (pt_geodm, ell);
%! 
%! %[pt_geod, pt_geod2]  % DEBUG
%! %max(abs(pt_geod2 - pt_geod))  % DEBUG
%! 
%! myassert (pt_geod2, pt_geod, -sqrt(eps))

%!test
%! clear convert_from_geodm
%! 
%! % first call loads function in memory.
%! % do not input pt_geodm otherwise we'd be caching for next call.
%! convert_from_geodm (pt_geodm+sqrt(eps), ell); 
%! 
%! % second call computes results:
%! t = cputime; Na = convert_from_geodm (pt_geodm, ell); ta = cputime - t;
%! 
%! % third call gets cached results:
%! t = cputime; Nb = convert_from_geodm (pt_geodm, ell); tb = cputime - t;
%! 
%! myassert (Na, Nb);
%! %[ta, tb]
%! % cputime_res applies to either ta or tb individually; tol applies to ta-tb;
%! tol = 2*cputime_res + sqrt(eps);
%! myassert (tb <= ta || abs(tb-ta) <= tol);

%!test
%! % is cache being updated?
%! pt_geodm1 = rand(n,3);
%! pt_geodm2 = rand(n,3);
%! clear compute_meridian_radius 
%! t = cputime; M1a = convert_from_geodm (pt_geodm1, ell); t1a = cputime - t;
%! t = cputime; M1b = convert_from_geodm (pt_geodm1, ell); t1b = cputime - t;
%! t = cputime; M2a = convert_from_geodm (pt_geodm2, ell); t2a = cputime - t;
%! t = cputime; M2b = convert_from_geodm (pt_geodm2, ell); t2b = cputime - t;
%! myassert (M1a, M1b);
%! myassert (M2a, M2b);
%! % cputime_res applies to either t2 or t3 individually; tol applies to t3-t2;
%! tol = 2*cputime_res + sqrt(eps);
%! %[t1a, t1b]
%! %[t2a, t2b]
%! myassert (t2b, t1b, -tol)

%!test
%! % cache should honour different ellipsoids!
%! ell1 = get_ellipsoid('fake');
%! ell2 = get_ellipsoid('grs80');
%! clear convert_from_geodm
%! pt_geod1 = convert_from_geodm (pt_geodm, ell1);
%! pt_geod2 = convert_from_geodm (pt_geodm, ell2);
%! myassert (~isequal(pt_geod2, pt_geod1))

