function X = trisolve_tri (B, Q, uplow)
    if isempty(B) || isempty(Q)
        X = [];
        return;
    end

    if (nargin < 3),  uplow = Q.uplow;  end
    if ~strncmpi(uplow, Q.uplow, 1)
        error ('packed:trisolve_tri:badUplow', ...
            '"uplow" asked is different than matrix''s uplow property.');
    end

    if ~strcmp(get_caller_name, 'trisolve'),
        error ('packed:trisolve_tri:privFunc', 'This is a private function.');
    end

    error (check_trisolve(B, Q));

    [info, X] = call_lapack ('tp', 'trs', ...
        Q.uplow, Q.order, size(B,2), Q.data, [], B, size(B,1));
    myassert (info >= 0);
end

%!test
%! % trisolve_tri ()
%! warning('off', 'test:noFuncCall');

%!error
%! s = lasterr ('', '');
%! trisolve_tri (packed(eye(2)));

%!test
%! % trisolve ()
%! s = lasterror;
%! myassert (s.identifier, 'packed:trisolve_tri:privFunc');


%!test
%! temp = trisolve ([], {packed([1 1 1], 'tri', 'u')}, 'pp');
%! myassert (isempty(temp));

%!test
%! temp = trisolve (eye(2), {packed([])}, 'pp');
%! myassert (isempty(temp));


%!test
%! % Here we use the positive-definite test matrices
%! % available in gallery().
%! 
%! warning ('off', 'MATLAB:singularMatrix');
%! warning ('off', 'MATLAB:nearlySingularMatrix');
%! warning ('off', 'trilin:trisolve:singularMatrix');
%! warning ('off', 'trilin:trisolve:nearlySingularMatrix');
%! 
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler', 'randcorr', 'pei', 'prolate'}, matrix_type = matrix_type{:};
%! for i=1:1
%! 
%! while true
%!     n = round (100 * rand);
%!     if (n > 1),  break;  end
%! end
%! 
%! A_full = cast(gallery(matrix_type, n), precision);
%! A_full = triu(A_full);
%! A = packed(A_full);
%!     myassert (ispacked(A));
%!     myassert (class(A), precision);
%! b = ones(n, 1);
%! 
%! %opts.POSDEF = false;
%! %opts.SYM = true;
%! %opts.RECT = true;
%! %x_full = linsolve (A_full, b, opts);
%! lastwarn('', '');
%! x_full = A_full \ b;
%! [w_full.message, w_full.identifier]= lastwarn;
%! 
%! lastwarn('', '');
%! [x, rcond] = trisolve (b, {A}, 'tri', norm(A, 1));
%! [w.message, w.identifier] = lastwarn;
%! 
%! issingular = false;
%! if    strend('singularMatrix', w_full.identifier) ...
%!    || strend('nearlySingularMatrix', w_full.identifier)
%!     issingular = true;
%!     myassert(   strend('singularMatrix', w.identifier) ...
%!            || strend('nearlySingularMatrix', w.identifier) );
%! end
%!
%! error = x - x_full;
%! 
%! disp({precision, matrix_type, eps(precision), rmse(error), rcond});  % DEBUG
%! 
%! if rcond > 0.1
%!     myassert ( rmse(error) < 10*eps(precision) );
%! end
%! 
%! end
%! end
%! end
%! 
%! warning ('on', 'MATLAB:singularMatrix');
%! warning ('on', 'MATLAB:nearlySingularMatrix');
%! warning ('on', 'trilin:trisolve:singularMatrix');
%! warning ('on', 'trilin:trisolve:nearlySingularMatrix');

%!test
%! warning('on', 'test:noFuncCall');

