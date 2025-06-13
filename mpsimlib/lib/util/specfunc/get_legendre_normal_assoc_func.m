function P = get_legendre_normal_assoc_func (n, t, force_c)
    if (nargin < 3),  force_c = [];  end
    assert(isscalar(n))
    [is_t_unique, tu, ignore, ind] = is_unique(t); %#ok<ASGLU>
    if is_t_unique
        P = get_legendre_normal_assoc_func_which (n, t, force_c);
    else
        Pu = get_legendre_normal_assoc_func_which (n, tu, force_c);
        P = Pu(:,:,ind);
    end
end

%!test
%! n = 100;
%! num_pts = 100;
%! in = rand(num_pts/2,1);
%! in = [in; in];
%! t = sin(in);
%! 
%! t0 = cputime;
%! P1 = get_legendre_normal_assoc_func (n, t);
%! t1 = cputime - t0;
%! 
%! t0 = cputime;
%! P2 = get_legendre_normal_assoc_func_which (n, t);
%! t2 = cputime - t0;
%! 
%! %max(abs(P1(:) - P2(:)))  % DEBUG
%! myassert(P1, P2)
%! 
%! %[n, num_pts, t1, t2]  % DEBUG
%! tol = cputime_tol();
%! myassert (t1 <= (t2 + tol));

