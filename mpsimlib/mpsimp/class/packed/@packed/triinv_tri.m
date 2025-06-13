function X = triinv_tri (Q, uplow)
    if isempty(Q)
        X = packed([]);
        return;
    end

    if ~strncmpi(uplow, Q.uplow, 1)
        uplow, Q.uplow
        error ('packed:triinv_tri:badUplow', ...
            '"uplow" asked is different than matrix''s uplow property.');
    end

    if ~strcmp(get_caller_name, 'triinv'),
        error ('packed:triinv_tri:privFunc', 'This is a private function.');
    end

    [info, temp] = call_lapack ('tp', 'tri', ...
        Q.uplow, Q.order, Q.data);
    myassert (info >= 0);
    X = packed(temp, 'tri', Q.uplow);
end

%!test
%! % triinv_tri()
%! % Here we use the positive-definite test matrices
%! % available in gallery().
%! 
%! for uplow = {'upper', 'lower'},  uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! %disp({uplow, precision, matrix_type});  % DEBUG
%! 
%! n = ceil(100 * rand);
%! 
%! A_full = gallery(matrix_type, n);
%! A_full = cast(A_full, precision);
%! A_full = triuplow(A_full, uplow);
%! A = packed(A_full, 'tri', uplow);
%!   myassert (ispacked(A));
%!   myassert (class(A), precision);
%! 
%! %Q2 = chol(A)
%! X_full = inv(A_full);
%! 
%! [Q, opt] = trifactor(A);
%!   myassert (ispacked(Q));
%!   %opt.uplow, uplow  % DEBUG
%!   myassert (strncmpi(opt.uplow, uplow, 1));
%! X = triinv(Q, opt);
%!   myassert (ispacked(X));
%! 
%! %full(X), X_full, X-X_full
%! temp = X - X_full;
%! %disp({n, max(abs(temp(:))), 100*eps(precision)});  % DEBUG
%! myassert (X, X_full, -100*eps(precision));
%! 
%! end
%! end
%! end

