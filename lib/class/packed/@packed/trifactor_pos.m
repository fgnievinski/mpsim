function [answer, info] = trifactor_pos (A, uplow)
    if isempty(A)
        answer = packed([]);
        info = 0;
        return;
    end
    
    if ~strncmpi(uplow, A.uplow, 1)
        error ('packed:trifactor_pos:badUplow', ...
            '"uplow" asked is different than matrix''s uplow property.');
    end

    if ~any(strcmp(get_caller_name, {'trifactor', 'chol'}))
        error ('packed:trifactor_pos:privFunc', 'This is a private function.');
    end
    
    [info, temp] = call_lapack ('pp', 'trf', ...
        A.uplow, A.order, A.data);

    myassert (info >= 0);
    if (info > 0) && (nargout < 2)
        error ('packed:trifactor_pos:notPosDef', ...
            'Matrix must be positive definite.');
    end
    answer = packed(temp, 'tri', A.uplow);
    if (info > 0) && (nargout >= 2)
        s.type = '()';
        s.subs = {1:info-1, 1:info-1};
        answer = subsref(answer, s);
        if ~ispacked(answer)
            answer = packed (answer);
        end
    end
end

%!test
%! % trifactor_pos
%! warning('off', 'test:noFuncCall');

%!error
%! s = lasterr ('', '');
%! chol(packed(logical([1 1 1]), 'tri', 'u'));

%!test
%! s = lasterror;
%! myassert (strend('nonFloatNotSupported', s.identifier));

%!error
%! s = lasterr ('', '');
%! chol(packed(complex([1 1 1]), 'tri', 'u'));

%!test
%! s = lasterror;
%! myassert (strend('complexNotSupported', s.identifier));

%!test
%! [R, p] = chol(packed([]));
%! myassert (isempty(R));
%! myassert (p, 0);

%!test
%! % Here we use the positive-definite test matrices
%! % available in gallery().
%! 
%! for precision = {'double', 'single'}
%!     precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}
%!     matrix_type = matrix_type{:};
%! for i=1:1
%!     while true
%!         n = round(100 * rand);
%!         if (n > 1),  break;  end
%!     end
%! 
%!     A_full = cast(gallery(matrix_type, n), precision);
%!     myassert(isa(A_full, precision));
%! 
%!     A = packed(A_full);
%!     myassert (ispacked(A))
%!     myassert(isa(A, precision));
%! 
%!     R_full = chol(A_full);
%!     R = chol(A);
%!     myassert (ispacked(R))
%! 
%!     error = full(R) - R_full;
%!     %disp({precision, matrix_type, i, n, ...
%!     %    max(abs(error(:))), 100*eps(precision)});  % DEBUG
%!     myassert (all( abs(error(:)) < 100*eps(precision) ));
%! 
%! 
%!     % break positive-definiteness:
%!     p = ceil(n / 2);
%!     A_full(p,p) = 0;  % break positive-definiteness
%!     A = packed(A_full);
%!     myassert (ispacked(A));
%!     
%!     try,
%!         R_full = chol(A_full);
%!     catch,
%!         try,
%!             R = chol(A);
%!         catch,
%!             s = lasterror;
%!             myassert (strend('notPosDef', s.identifier));
%!         end
%!     end
%!     
%!     [R_full, p1] = chol(A_full);
%!     [R, p2] = chol(A);
%!     myassert (p2, p1);    
%!     myassert (size(R), size(R_full));    
%!     error = abs(full(R) - R_full);
%!     myassert (all( error(:) < 100*eps(precision) ));
%!  
%! end
%! end
%! end

%!test
%! warning('on', 'test:noFuncCall');

