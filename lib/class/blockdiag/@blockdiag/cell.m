function answer = cell (A)
    answer = A.data;
end

%!test
%! temp = blockdiag(1, 2);
%! myassert (cell(temp), {[1], []; [], [2]});

