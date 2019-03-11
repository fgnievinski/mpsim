function answer = order (A)
    answer = A.order;
end

%!test
%! myassert (order(packed), 0);
%! myassert (order(packed(eye(2))), 2);
%! myassert (order(packed(eye(3))), 3);

