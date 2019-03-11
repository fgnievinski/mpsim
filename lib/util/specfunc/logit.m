function out = logit (in)
    out = log(in ./ (1 - in));
end

%!test
%! n = 5;
%! x = randint (-10, +10, n, 1);
%! p = logitinv(x);
%! 
%! idx = (0 <= p & p <= 1);
%!   [x, p, idx]  % DEBUG
%! assert(all(idx))
%! 
%! y = logit(p);
%!   [x, y, y-x]  % DEBUG
%! myassert(x, y, -sqrt(eps()))
