function answer = power (left, right)
    error(check_op (left, right, 'power', 'packed:power'));
    answer = do_op (left, right, 'power');
end

%!test
%! % power
%! global DO_OP
%! DO_OP = 'power';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

