function answer = norm (A, p)
    if (nargin < 2),  p = 2;  end  % Matlab's norm() behaviour
    myassert (ispacked(A));

    if isempty(A)
        answer = 0;
        return;
    end
    
    switch p
    case 1
        type = '1';
    case 2
        error ('packed:norm:twoNormNotSupported', ...
        '2-norm is not supported for packed matrices.');
    case Inf
        type = 'I';
    case 'fro'
        type = 'F';
    otherwise
        error ('packed:norm:unknownNorm', ...
        'The only matrix norms available are 1, 2, inf, and ''fro''');
    end

    if     issym_type(A)
        answer = call_lapack ('sp', 'lan', ...
            type, A.uplow, A.order, A.data);
    elseif istri_type(A)
        answer = call_lapack ('tp', 'lan', ...
            type, A.uplow, A.order, A.data);
    end
end


%!error
%! s = lasterr ('', '');
%! temp = packed(logical([1 1 1]), 'tri', 'u');
%! norm(temp, 1);

%!test
%! % norm ()
%! s = lasterror;
%! myassert (strend('nonFloatNotSupported', s.identifier));

%!error
%! s = lasterr ('', '');
%! norm(packed(complex([1 1 1]), 'tri', 'u'), 1);

%!test
%! % norm ()
%! s = lasterror;
%! myassert (strend('complexNotSupported', s.identifier));

%!test
%! temp = norm(packed([]));
%! myassert (temp, 0);
%! temp = norm([]);
%! myassert (temp, 0);

%!test
%! for precision = {'single', 'double'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for packed_type = {'sym', 'tri'}, packed_type = packed_type{:};
%! for norm_type = {1, Inf, 'fro'}, norm_type = norm_type{:};
%!     %disp({precision, matrix_type, packed_type, norm_type});  % DEBUG
%!     n = 1 + ceil(100*rand);
%!     
%!     A_full = cast(gallery(matrix_type, n), precision);
%!         myassert(isa(A_full, precision));
%!     if strcmp(packed_type, 'tri')
%!         A_full = triu(A_full);
%!     end
%!     
%!     idx = triu(true(n));
%!     A = packed (A_full(idx), packed_type, 'u');
%!         myassert (ispacked(A));
%!         myassert (isa(A, precision));
%! 
%!     if strcmp(packed_type, 'sym')
%!         myassert (issym(A_full));
%!         myassert (issym(A));
%!     elseif strcmp(packed_type, 'tri')
%!         myassert (istriu(A_full));        
%!         myassert (istriu(A));        
%!     end
%!     
%!     answer_full = norm(A_full, norm_type);
%!       myassert(isa(answer_full, precision))
%!     answer = norm (A, norm_type);
%!       myassert(isa(answer, precision))
%! 
%!     error = answer - answer_full;
%!     tol = 100*sqrt(eps(answer_full));
%! 
%!     %disp({answer, answer_full, error, tol});  % DEBUG
%!     myassert(answer, answer_full, -tol)
%! end
%! end
%! end
%! end

