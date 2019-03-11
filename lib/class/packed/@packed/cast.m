function answer = cast (A, newclass)
    if (nargin < 2)
        error('packed:cast:notEnoughInputs', ...
        'Not enough input parameters.');
    end
    answer = A;
    answer.data = cast (answer.data, newclass);
end

%!test
%! A = packed(eye(2,2));
%!   myassert (class(A), 'double');
%! A = cast (A, 'double');
%!   myassert (class(A), 'double');
%! A = cast (A, 'single');
%!   myassert (class(A), 'single');
%! A = cast (A, 'logical');
%!   myassert (class(A), 'logical');
%! A = cast (A, 'uint8');
%!   myassert (class(A), 'uint8');

%!error
%! lasterr ('', '');
%! cast(packed([]))
 
%!test
%! % cast ()
%! s = lasterror;
%! myassert (s.identifier, 'packed:cast:notEnoughInputs');
