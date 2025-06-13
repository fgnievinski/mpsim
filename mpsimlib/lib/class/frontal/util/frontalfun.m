function out = frontalfun(fun, in)
    if (isvector(in)),  in = reshape(in, 1, 1, length(in));  end
    [m,n] = size(fun(in(:,:,1)));
    o = size(in,3);
    out = zeros(m,n,o);
    for k=1:o
        out(:,:,k) = fun(in(:,:,k));
    end
end

%!test
%! m = 2;
%! n = 3;
%! o = 4;
%! in = rand(m,n,o);
%! out = exp(in);
%! out2 = frontalfun(@exp, in);
%! %out, out2, out2-out  % DEBUG
%! myassert(out2, out);

