function B = mtimes_diag (d, A)
    if ~isvector(d),  d = diag(d);  end
    B = bsxfun(@times, d, A);
end

%!test
%! n = 5;
%! m = 6;
%! A = rand(n,m);
%! d = rand(n,1);
%! D = diag(d);
%! B = D * A;
%! B2 = mtimes_diag (d, A);
%! B3 = mtimes_diag (D, A);
%! myassert(B2, B)
%! myassert(B3, B)

