function out = logitinv (in)
    out = 1 ./ (1 + exp(-in));
end

%!test
%! % logitinv()
%! test('logit')
