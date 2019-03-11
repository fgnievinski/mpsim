function P = get_legendre_normal_assoc_func_which (n, t, force_c)
    if (nargin < 3),  force_c = [];  end
    % the C version seems always faster than the Matlab version:
    if isempty(force_c),  force_c = true;  end
    if ( force_c || (length(t) <= (n+1)^2) )
        try
            P = get_legendre_normal_assoc_func_c (n, t);
            return
        catch
        end
    end
    P = get_legendre_normal_assoc_func_m (n, t);
end

%!test
%! % (length(t) < (n+1)^2)
%! % get_legendre_normal_assoc_func_which()
%! n = 360;
%! num_pts = 10;
%! t = sin(rand(num_pts,1));
%! 
%! t0 = cputime;
%! Pm = get_legendre_normal_assoc_func_m (n, t);
%! tm = cputime - t0;
%! 
%! t0 = cputime;
%! Pc = get_legendre_normal_assoc_func_c (n, t);
%! tc = cputime - t0;
%! 
%! %max(abs(Pc(:) - Pm(:)))  % DEBUG
%! myassert(Pc, Pm, -eps);
%! 
%! [n, num_pts, tm, tc]  % DEBUG
%! tol = cputime_tol;
%! myassert (tc <= (tm + tol));

%!test
%! % (length(t) > (n+1)^2)
%! % get_legendre_normal_assoc_func_which()
%! n = 10;
%! num_pts = 1000;
%! num_pts = 10000;
%! t = sin(rand(num_pts,1));
%! 
%! t0 = cputime;
%! Pm = get_legendre_normal_assoc_func_m (n, t);
%! tm = cputime - t0;
%! 
%! t0 = cputime;
%! Pc = get_legendre_normal_assoc_func_c (n, t);
%! tc = cputime - t0;
%! 
%! %max(abs(Pc(:) - Pm(:)))  % DEBUG
%! myassert(Pc, Pm, -eps);
%! 
%! [n, num_pts, tm, tc]  % DEBUG
%! tol = cputime_tol;
%! myassert (tm <= (tc + tol));

