function answer = iseven (x)
    answer = ~isodd(x);
end

%!test
%! myassert(~iseven(1))
%! myassert( iseven(2))
%! myassert(~iseven(3))

