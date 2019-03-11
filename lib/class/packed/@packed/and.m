function answer = and (left, right)
    error(check_op (left, right, 'and', 'packed:and'));
    answer = do_op (left, right, 'and');
end

%!test
%! % and
%! global DO_OP
%! DO_OP = 'and';
%! test('do_op', 'packed', 'private')
%! clear global DO_OP

