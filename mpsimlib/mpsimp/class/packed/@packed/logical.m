function answer = logical (A)
    answer = A;
    answer.data = logical (answer.data);
end

%!test
%! A = packed(eye(2,2));
%!   myassert (class(A), 'double');
%! 
%! A = logical (A);
%!   myassert (class(A), 'logical');
%! 
%! A = cast (A, 'double');
%!   myassert (class(A), 'double');
%! A = logical (A);
%!   myassert (class(A), 'logical');
%! 
%! A = cast (A, 'logical');
%!   myassert (class(A), 'logical');
%! A = logical (A);
%!   myassert (class(A), 'logical');
%! 
%! A = cast (A, 'uint8');
%!   myassert (class(A), 'uint8');
%! A = logical (A);
%!   myassert (class(A), 'logical');

