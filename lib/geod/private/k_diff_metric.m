function k = k_diff_metric (base, ell)
    lat = base(:, 1);
    h   = base(:, 3);
    
    M = compute_meridian_radius (lat, ell);
    N = compute_prime_vertical_radius (lat, ell);

    k = [...
        pi/180 .* (h + M), ...
        pi/180 .* (h + N) .* cos(lat*pi/180), ...
        ones(size(base, 1), 1)
    ];
end

%!test
%! n = 2;
%! pt_geod = rand_pt_geod (n);
%! pt_geod(1,1) =  0;
%! pt_geod(2,1) = 90;
%! %pt_geod  % DEBUG
%! ell.a = 1;  ell.b = ell.a;  ell.e = 0;  ell.f = 0;
%! 
%! answer = k_diff_metric (pt_geod, ell);
%! 
%! myassert(size(answer), [n, 3]);
%! myassert( answer(:,3), 1, -sqrt(eps) );
%! myassert( answer(:,1), pi/180*(ell.a + pt_geod(:,3)), -sqrt(eps) );
%! myassert( answer(1,2), pi/180*(ell.a + pt_geod(1,3)), -sqrt(eps) )
%! myassert( answer(2,2), 0, -sqrt(eps) );

