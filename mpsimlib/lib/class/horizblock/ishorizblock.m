function answer = ishorizblock(A)
    answer = isa(A, 'horizblock');
end

%!test
%! A = horizblock;
%! myassert (ishorizblock(A));

%!test
%! A = 0;
%! myassert (~ishorizblock(A));

%!test
%! A = sparse(0);
%! myassert (~ishorizblock(A));

%!test
%! A = cell(1);
%! myassert (~ishorizblock(A));

