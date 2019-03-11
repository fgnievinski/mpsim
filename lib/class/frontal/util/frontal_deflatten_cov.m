function A = frontal_deflatten_cov (A)
    A = frontal_reshape(frontal_deflatten(A, 1), [1 1].*sqrt(size(A,2)));
end

%!test
%! in = cat(1, 1:4, 5:8);
%! out = cat(3, [1 2; 3 4]', [5 6; 7 8]');
%! out2 = frontal_deflatten_cov (in);
%! %in, out, out2  % DEBUG
%! myassert(out2, out)
