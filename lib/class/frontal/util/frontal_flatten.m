function A = frontal_flatten (A)
    [m,n,p] = size(A);
    A = transpose(reshape(frontal_transpose(A),[n,m*p,1]));
end

%!test
%! in = cat(3, [1 2 3], [4 5 6]);
%! out = cat(1, [1 2 3], [4 5 6]);
%! out2 = frontal_flatten (in);
%! %out2, out  % DEBUG
%! myassert(out2, out)
