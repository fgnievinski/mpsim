function answer = order (A)
    if A.size(1) ~= A.size(2)
        error ('blockdiag:order:nonSquare', ...
            'Order undefined for non-square matrices.');
    end
    answer = A.size(1);
end

%!test
%! myassert (order(blockdiag), 0);
%! myassert (order(blockdiag(eye(2), eye(3))), 5);
%! myassert (order(blockdiag(1,2,3)), 3);

%!error
%! lasterr ('', '');
%! order(blockdiag(eye(2), eye(3,2)))

%!test
%! % order ()
%! s = lasterror;
%! myassert (s.identifier, 'blockdiag:order:nonSquare');

