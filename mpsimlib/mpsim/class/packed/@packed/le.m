function answer = le (left, right)
    error(check_op (left, right, 'le', 'packed:le'));
    answer = do_op (left, right, 'le');
end

%!test
%! % le
%! global DO_OP
%! DO_OP = 'le';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

