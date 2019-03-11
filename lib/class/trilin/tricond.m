function answer = tricond (A_norm, Q, opt)
    if ~isscalar(A_norm)
        error ('trilin:tricond:notScalar', ...
            'Input norm should be a scalar.');
    end
    if ~isfield(opt, 'do_warn') || isempty(opt.do_warn)
        opt.do_warn = false;
    end
    if ~isfield(opt, 'uplow') || isempty(opt.uplow)
        opt.uplow = 'upper';
    end

    if (nargout < 1) && ~opt.do_warn,  return;  end

    if isempty(Q) || isempty(A_norm)
        answer = [];
        return;
    end
    
    if ~isfield(opt, 'type') || isempty(opt.type)
        error ('trilin:tricond:missingType', ...
            'Missing matrix type.');
    end    
    switch opt.type(1)
    case 'd'  % diagonal
        answer = tricond_diag (A_norm, Q);
    case 't'  % triangular
        answer = tricond_tri (A_norm, Q, opt.uplow);
    case 'p'  % positive-definite
        answer = tricond_pos (A_norm, Q, opt.uplow);
    case 's'  % symmetric indefinite
        answer = tricond_sym (A_norm, Q, opt.Q2, opt.uplow);
    case 'g'  % general
        answer = tricond_gen (A_norm, Q, opt.Q2);
    otherwise
        error ('trilin:tricond:unknownOpt', ...
            'Unknown opt.type (%s).', opt.type);
    end

    if ~opt.do_warn,  return;  end
    if (answer == 0)
        warning ('trilin:tricond:singularMatrix', ...
        'Matrix is singular to working precision.');
    elseif (answer < eps(class(Q)))
        warning ('trilin:tricond:nearlySingularMatrix', ...
        ['Matrix is close to singular or badly scaled.\n', ...
        '         Results may be inaccurate. RCOND = %g.'], answer);
    end
end        


%!error
%! lasterr ('', '');
%! out = tricond (eye(2), eye(2), struct('type','pos'));

%!test
%! % tricond ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:tricond:notScalar');


%!error
%! lasterr ('', '');
%! out = tricond (eye(1), eye(2), struct('type','WRONG'));

%!test
%! % tricond ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:tricond:unknownOpt');




%!shared
%! for i=1:10
%! n = 1 + ceil(10*rand);

%!test
%! A = rand(1,1);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, 1, -10*eps);
%! end % for

%!test
%! A = rand*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -1e3*eps);
%! end % for

%!test
%! A = triu(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -10*eps);
%! end % for

%!test
%! A = tril(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -10*eps);
%! end % for

%!test
%! A = gallery('minij', n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'positive', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -10*eps);
%! end % for

%!test
%! A = gallery('minij', n) - 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'symmetric', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -10*eps);
%! end % for

%!test
%! A = rand(n) + 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'general', 1));
%! X = tricond (norm(A,1), Q, opt);
%! myassert (X, rcond(A), -10*eps);
%! end % for

%!test
%! opt.do_warn = false;
%! tricond (1, [], opt);

