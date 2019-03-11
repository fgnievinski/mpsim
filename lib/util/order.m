function answer = order (A)
    [m,n,o] = size(A);
    myassert( (m==n) && (o==1) )
    answer = m;
end

%!test
%! n = ceil(10*rand);
%! n2 = order(eye(n));
%! myassert(n2, n2)

