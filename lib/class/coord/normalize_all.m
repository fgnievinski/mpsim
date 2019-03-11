function [out, out2] = normalize_all (in)
    out2 = norm_all(in);
    idx = (out2 == 0);
    out2(idx) = 1;  % avoid div by zero.
    out = divide_all(in, out2);
    out(idx,:) = 0;
    out2(idx) = 0;
end

%!test
%! n = ceil(10*rand);
%! in = rand(n,3);
%! [out, out2] = normalize_all (in);
%! myassert(norm_all(out), ones(n,1), -10*eps);
%! myassert(out.*repmat(out2,1,3), in, -10*eps);

%!test
%! % special case:
%! myassert(normalize_all([0 0 0]), [0, 0, 0])
