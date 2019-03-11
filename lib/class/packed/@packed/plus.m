function answer = plus (left, right)
    error(check_op (left, right, 'plus', 'packed:plus'));
    answer = do_op (left, right, 'plus');
end

%!test
%! % plus
%! global DO_OP
%! DO_OP = 'plus';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

