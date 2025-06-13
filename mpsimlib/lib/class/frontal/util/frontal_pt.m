function out = frontal_pt (in)
    [m,n,p] = size(in);
    myassert(p==1);
    out = reshape(in.', 1, n, m);
end

%!test
%! % complex-valued input:
%! m = ceil(10*rand);
%! n = ceil(10*rand);
%! in = rand(m,n);
%! in = complex(in, in);
%! out = frontal_pt(in);
%! in2 = defrontal_pt(out);
%! %in2, in  % DEBUG
%! myassert(in2, in);

