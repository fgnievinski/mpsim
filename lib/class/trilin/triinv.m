function X = triinv (Q, opt, get_full)
    if (nargin < 3),  get_full = false;  end
        
    if ~isfield(opt, 'uplow') || isempty(opt.uplow)
        opt.uplow = 'U';
    end

    if ~isfield(opt, 'type') || isempty(opt.type)
        error ('trilin:tricond:missingType', ...
            'Missing matrix type.');
    end    
    switch opt.type(1)
    case 'd'  % diagonal
        X = triinv_diag (Q);
    case 't'  % triangular
        X = triinv_tri (Q, opt.uplow);
    case 'p'  % positive-definite
        X = triinv_pos (Q, opt.uplow);
    case 's'  % symmetric indefinite
        X = triinv_sym (Q, opt.Q2, opt.uplow);
    case 'g'  % general
        X = triinv_gen (Q, opt.Q2);
    otherwise
        error ('trilin:triinv:unknownOpt', ...
            'Unknown opt.type (%s).', opt.type);
    end

    if get_full,  X = trifull (X, opt);  end
end        


%!error
%! lasterr ('', '');
%! triinv (eye(1), struct('type','WRONG'));

%!test
%! % triinv ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:triinv:unknownOpt');

%!shared
%! for i=1:10
%! n = 1 + ceil(10*rand);

%!test
%! A = rand(1,1);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = triinv (Q, opt, true);
%! X2 = inv(A);
%! %A, Q, X, X2, X - X2  % DEBUG
%! myassert (X, X2, -100*eps);
%! end % for

%!test
%! A = rand*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = triinv (Q, opt, true);
%! X2 = inv(A);
%! %A, Q, X, X2, X - X2  % DEBUG
%! myassert (X, X2, -100*eps);
%! end % for

%!test
%! A = triu(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! X = triinv (Q, opt, true);
%! myassert (X, inv(A), -10*eps);
%! end % for

%!test
%! A = tril(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! X = triinv (Q, opt, true);
%! myassert (X, inv(A), -10*eps);
%! end % for

%!test
%! A = gallery('minij', n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'positive', 1));
%! X = triinv (Q, opt, true);
%! myassert (X, inv(A), -10*eps);
%! end % for

%!test
%! A = gallery('minij', n) - 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'symmetric', 1));
%! X = triinv (Q, opt, true);
%! myassert (X, inv(A), -10*eps);
%! end % for

%!test
%! A = rand(n) + 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'general', 1));
%! X = triinv (Q, opt, true);
%! %X, inv(A)  % DEBUG
%! myassert (X, inv(A), -10*eps);
%! end % for

