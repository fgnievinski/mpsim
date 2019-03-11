function answer = times (left, right)
    error(check_op (left, right, 'times', 'packed:times'));
    answer = do_op (left, right, 'times');
end

%!test
%! % times
%! global DO_OP
%! DO_OP = 'times';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

