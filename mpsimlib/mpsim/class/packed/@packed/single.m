function answer = single (A)
    answer = A;
    answer.data = single (answer.data);
end

%!test
%! A = packed(eye(2,2));
%!   myassert (class(A), 'double');
%! 
%! A = single (A);
%!   myassert (class(A), 'single');
%! 
%! A = cast (A, 'double');
%!   myassert (class(A), 'double');
%! A = single (A);
%!   myassert (class(A), 'single');
%! 
%! A = cast (A, 'logical');
%!   myassert (class(A), 'logical');
%! A = single (A);
%!   myassert (class(A), 'single');
%! 
%! A = cast (A, 'uint8');
%!   myassert (class(A), 'uint8');
%! A = single (A);
%!   myassert (class(A), 'single');
