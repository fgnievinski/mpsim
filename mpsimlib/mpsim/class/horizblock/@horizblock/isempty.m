function answer = isempty(A)
    answer = isempty(cell(A));
end

%!test
%! temp = horizblock();
%! myassert(ishorizblock(temp));
%! myassert(isempty(temp));

%!test
%! temp = horizblock(1, 2);
%! myassert(ishorizblock(temp));
%! myassert(~isempty(temp));

