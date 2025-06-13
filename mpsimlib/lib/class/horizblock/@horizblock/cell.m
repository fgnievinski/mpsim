function answer = cell (A)
    answer = A.data;
end

%!test
%! temp = horizblock(1, 2);
%! %cell(temp)  % DEBUG
%! myassert (cell(temp), {[1], [2]});

