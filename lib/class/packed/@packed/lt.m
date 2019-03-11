function answer = lt (left, right)
    error(check_op (left, right, 'lt', 'packed:lt'));
    answer = do_op (left, right, 'lt');
end

%!test
%! % lt
%! global DO_OP
%! DO_OP = 'lt';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

