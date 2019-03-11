function vec = deal_out2vec (f, n_out)
    [cel{1:n_out}] = f();
    vec = cell2mat(reshape(cel, [1 n_out]));
end

%!test
%! in = rand(3,1);
%! f = @() min(in);
%! [a, b] = f();
%! vec = [a b];
%! vec2 = deal_out2vec (f, 2);
%! myassert(vec2, vec)
