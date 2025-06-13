function answer = double (A)
    answer = A;
    answer.data = double (answer.data);
end

%!test
%! A = packed(eye(2,2));
%!   myassert (class(A), 'double');
%! 
%! A = double (A);
%!   myassert (class(A), 'double');
%! 
%! A = cast (A, 'single');
%!   myassert (class(A), 'single');
%! A = double (A);
%!   myassert (class(A), 'double');
%! 
%! A = cast (A, 'logical');
%!   myassert (class(A), 'logical');
%! A = double (A);
%!   myassert (class(A), 'double');
%! 
%! A = cast (A, 'uint8');
%!   myassert (class(A), 'uint8');
%! A = double (A);
%!   myassert (class(A), 'double');
