function answer = minus (left, right)
    error(check_op (left, right, 'minus', 'packed:minus'));
    answer = do_op (left, right, 'minus');
end

%!test
%! % minus
%! global DO_OP
%! DO_OP = 'minus';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

