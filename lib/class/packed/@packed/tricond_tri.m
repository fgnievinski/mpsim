function answer = tricond_tri (A_norm, Q)
    if ~strcmp(get_caller_name, 'tricond'),
        error ('packed:tricond_tri:privFunc', 'This is a private function.');
    end

    myassert (ispacked(Q));
    myassert (istri_type(Q));

    clear A_norm
    [info, answer] = call_lapack ('tp', 'con', ...
        Q.uplow, Q.order, Q.data, [], []);
    myassert (info >= 0);
end

%!test
%! % tricond_tri ()
%! warning('off', 'test:noFuncCall');

%!error
%! s = lasterr ('', '');
%! tricond_tri (packed(eye(2)));

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:tricond_tri:privFunc');


%!error
%! s = lasterr ('', '');
%! rcond(packed(complex([1 1 1]), 'tri', 'u'));

%!test
%! % rcond ()
%! s = lasterror;
%! myassert (strend('complexNotSupported', s.identifier));

%!test
%! temp = tricond(rand, {packed([])}, 'tri');
%! myassert (temp, Inf);
%! temp = rcond([]);
%! myassert (temp, Inf);

%!test
%! for precision = {'single', 'double'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler', 'randcorr', 'pei', 'prolate'}, matrix_type = matrix_type{:};
%! for i=1:1
%!     while true
%!         n = round(100*rand);
%!         if (n > 1),  break;  end
%!     end
%!     
%!     A_full = cast(gallery(matrix_type, n), precision);
%!         myassert (issym(A_full));
%!         myassert(isa(A_full, precision));
%!     A_full = triu (A_full);
%! 
%!     A = packed (A_full, 'tri', 'u');
%!         myassert (ispacked(A));
%!         myassert (istriu(A));
%!         myassert (isa(A, precision));
%!     
%!     answer_full = rcond(A_full);
%!     answer = tricond (0, {A}, 'triangular');
%!     error = answer - answer_full;
%!     
%!     %disp({precision, matrix_type, answer_full, answer, error, 100*eps(precision), class(answer)});  % DEBUG
%! 
%!     myassert(    ( answer_full >= 0.25 && abs(error) < 1e5*eps(precision) )...
%!             || ( answer_full <  0.25 && abs(error) < 0.1 ) );
%!     % It seems that, when the condition number is small, its estimate
%!     % is not very reliable.
%! end
%! end
%! end

%!test
%! warning('on', 'test:noFuncCall');

