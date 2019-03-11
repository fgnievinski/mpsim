function J = spzerocol (J, idx_nan)
    if ~issparse(J),  J(idx_nan,:) = 0;  return;  end        
    [m,n] = size(J);
    [i,j,s] = find(J);
    ind_nan = find(idx_nan);
    idx = ~ismember(i, ind_nan);
    J = sparse(i(idx), j(idx), s(idx), m, n);
end

%!test
%! m = 10000;
%! n = 100;
%! density = 0.1;
%! R = sprand(m,n,density);
%! idx = (rand(m,1) > 0.5);
%! 
%! t = cputime;
%! Ra = R;  Ra(idx,:) = sparse(0);
%! ta = cputime - t;
%! 
%! t = cputime;
%! Rb = spzerocol(R, idx);
%! tb = cputime - t;
%! 
%! tol = cputime_tol();
%! %[ta, tb, ta+tol]  % DEBUG
%! myassert (tb <= (ta + tol));


