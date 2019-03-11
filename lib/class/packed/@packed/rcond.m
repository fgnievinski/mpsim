function answer = rcond (A)
    answer = tri_rcond (A);
end

%!test
%! temp = rcond(packed([]));
%! myassert (temp, Inf);
%! temp = rcond([]);
%! myassert (temp, Inf);


%!error
%! s = lasterr ('', '');
%! rcond(packed(logical([1 1 1]), 'tri', 'u'));

%!test
%! % rcond ()
%! s = lasterror;
%! myassert (strend('nonFloatNotSupported', s.identifier));



%!test
%! for precision = {'single', 'double'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:1
%!     while true
%!         n = round(100*rand);
%!         if (n > 1),  break;  end
%!     end
%!     
%!     A_full = cast(gallery(matrix_type, n), precision);
%!         myassert (issym(A_full));
%!         myassert(isa(A_full, precision));
%!     
%!     A = packed (A_full, 'sym', 'u');
%!         myassert (ispacked(A));
%!         myassert (issym(A));
%!         myassert (isa(A, precision));
%!     
%!     answer_full = rcond(A_full);
%!     answer = rcond(A);
%!     error = answer - answer_full;
%!     
%!     %disp({precision, matrix_type, answer_full, answer, error, 100*eps(precision)});  % DEBUG
%!     myassert(    ( answer_full >= 0.25 && abs(error) < 1e5*eps(precision) )...
%!             || ( answer_full <  0.25 && abs(error) < 0.1 ) );
%!     % It seems that, when the condition number is small, its estimate
%!     % is not very reliable.
%! end
%! end
%! end

