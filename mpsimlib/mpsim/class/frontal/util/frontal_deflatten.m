function A = frontal_deflatten (A, q)
    [m,n,p] = size(A);
      assert(p == 1);
    A = frontal_transpose(reshape(transpose(A),[n,q,m/q]));
end

%!shared
%! in = cat(1, [1 2 3], [4 5 6]);

%!test
%! out = cat(3, [1 2 3], [4 5 6]);
%! out2 = frontal_deflatten (in, 1);
%! %in, out, out2  % DEBUG
%! myassert(out2, out)

%!test
%! in0 = in;
%! in = repmat(in0, [2,1,1]);
%! out = repmat(in0, [1,1,2]);
%! out2 = frontal_deflatten (in, 2);
%! %in, out, out2  % DEBUG
%! myassert(out2, out)
