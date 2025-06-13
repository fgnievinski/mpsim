function answer = eq (left, right)
    error(check_op (left, right, 'eq', 'packed:eq'));
    answer = do_op (left, right, 'eq');
end

%!test
%! % eq
%! global DO_OP
%! DO_OP = 'eq';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

