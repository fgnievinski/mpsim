function X = trisolve (B, Q, opt)
    error(nargchk2 (3, 3, nargin, 'struct', 'trilin:trisolve'));    

    if isempty(B) || isempty(Q)
        X = [];
        return;
    end
    
    if xor(isa(B, 'single'), isa(Q, 'single'))
        Q = single(Q);
        B = single(B);
        % see section Data Type Support in doc mldivide.
    end

    if ~isfield(opt, 'trans') || isempty(opt.trans)
        opt.trans = 'N';
    end

    if ~isfield(opt, 'uplow') || isempty(opt.uplow)
        opt.uplow = 'U';
    end

    if ~isfield(opt, 'type') || isempty(opt.type)
        error ('trilin:tricond:missingType', ...
            'Missing matrix type.');
    end    
    switch opt.type(1)
    case 'd'  % diagonal
        X = trisolve_diag(B, Q);
    case 't'  % triangular
        X = trisolve_tri (B, Q, opt.uplow, opt.trans);
    case 'p'  % positive-definite
        X = trisolve_pos (B, Q, opt.uplow);
    case 's'  % symmetric indefinite
        X = trisolve_sym (B, Q, opt.Q2, opt.uplow);
    case 'g'  % general
        X = trisolve_gen (B, Q, opt.Q2);
    otherwise
        error ('trilin:trisolve:unknownOpt', ...
            'Unknown opt.type (%s).', opt.type);
    end
end

%!error
%! s = lasterr ('', '');
%! trisolve (ones(2,1), triu(ones(2)), struct('type','WRONG'));

%!test
%! % trisolve ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:trisolve:unknownOpt');


%!test
%! X = trisolve ([], eye(2), struct('type','pos'));
%! myassert (isempty(X));


%!test
%! X = trisolve (eye(2), [], struct('type','pos'));
%! myassert (isempty(X));


%!shared
%! for i=1:10
%! n = 1 + ceil(10*rand);
%! n2 = ceil(10*rand);
%! B = rand(n, n2);
%! %end  for's end is at the end of each test section.

%!test
%! A = rand(1,1);
%! B = rand(1,n2);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -1e3*eps);
%! end % for

%!test
%! A = rand*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! X = trisolve (B, Q, opt);
%! X2 = A\B;
%! %X, X2  % DEBUG
%! myassert (X, X2, -1e3*eps);
%! end % for

%!test
%! A = triu(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! 
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -10*eps);
%! 
%! opt.trans = 't';
%! X = trisolve (B, Q, opt);
%! myassert (X, A'\B, -10*eps);
%! end % for

%!test
%! A = tril(ones(n));
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'triangular', 1));
%! 
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -10*eps);
%! 
%! opt.trans = 't';
%! X = trisolve (B, Q, opt);
%! myassert (X, A'\B, -10*eps);
%! end % for

%!test
%! A = gallery('minij', n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'positive', 1));
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -10*eps);
%! end % for

%!test
%! A = gallery('minij', n) - 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'symmetric', 1));
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -10*eps);
%! end % for

%!test
%! A = rand(n) + 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'general', 1));
%! X = trisolve (B, Q, opt);
%! myassert (X, A\B, -10*eps);
%! end % for

