function answer = isodd (x)
    answer = (mod(x,2) == 1);
end

%!test
%! myassert(isodd(1))
%! myassert(~isodd(2))
%! myassert(isodd(3))

