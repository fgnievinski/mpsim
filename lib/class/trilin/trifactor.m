function [Q, opt] = trifactor (A, opt)
    if (nargin < 2),  opt = struct();  end
    if ~isfield(opt, 'type'),  opt.type = '';  end
    if ~isfield(opt, 'uplow'),  opt.uplow = '';  end

    %%
    if isempty(A)
        Q = [];
        opt.type = '';
        opt.uplow = '';
        return;
    end
   
    %% 
    if ~isempty(opt.type),  switch opt.type(1)
    case 'd'  % diagonal
        Q = trifactor_diag (A);
        opt.uplow = '';
    case 't'  % triangular
        myassert(~isempty(opt.uplow))
        Q = trifactor_tri (A);
    case 'p'  % positive-definite
        if isempty(opt.uplow),  opt.uplow = tri_uplow(A);  end
        Q = trifactor_pos (A, opt.uplow);
    case 's'  % symmetric indefinite
        if isempty(opt.uplow),  opt.uplow = tri_uplow(A);  end
        [Q, opt.Q2] = trifactor_sym (A, opt.uplow);
    case 'g'  % general
        [Q, opt.Q2] = trifactor_gen (A);
    otherwise
        error ('trilin:trifactor:unknownOpt', ...
            'Unknown opt.type (%s).', opt.type);
    end,  return;  end

    %%
    if isscalar(A) || isdiag(A)
        Q = trifactor_diag (A);
        opt.type = 'diagonal';
    elseif istriu(A)
        Q = A;
        opt.type = 'triangular';
        opt.uplow = 'upper';
    elseif istril(A)
        Q = A;
        opt.type = 'triangular';
        opt.uplow = 'lower';
    elseif issym(A)
        if isempty(opt.uplow),  opt.uplow = tri_uplow(A);  end
        try
            Q = trifactor_pos (A, opt.uplow);
            opt.type = 'positive-definite';
        catch
            s = lasterror;
            if    ~strendi('notPosDef', s.identifier) ...
               && ~strendi('PosDef', s.identifier)
                rethrow (s);
            end
            [Q, opt.Q2] = trifactor_sym (A, opt.uplow);
            opt.type = 'symmetric indefinite';
        end
    else
        [Q, opt.Q2] = trifactor_gen (A);
        opt.type = 'general';
        opt.uplow = '';
    % TODO: elseif issquare(A), trifactor_gen (A); else QR(A);
    end
end

%!test
%! % empty matrix.
%! A = [];
%! [Q, opt] = trifactor (A);
%! myassert (isempty(Q));
%! myassert (isstruct(opt));
%! myassert (isempty(opt.type));
%! myassert (isempty(opt.uplow));

%! % let trifactor guess the matrix type:

%!test
%! A = rand;
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! myassert (size(Q), [1,1]);
%! myassert (Q, A);

%!test
%! n = 10;
%! A = eye(n);
%! [Q, opt] = trifactor (A);
%! %Q, A  % DEBUG
%! myassert (strncmp(opt.type, 'diagonal', 1));
%! myassert (isvector(Q) && length(Q) == n);
%! myassert (Q, diag(A));

%!test
%! n = 10;
%! A = triu(ones(n));
%! [Q, opt] = trifactor (A);
%! %Q, A  % DEBUG
%! myassert (strncmp(opt.type, 'triangular', 1));
%! myassert (strncmp(opt.uplow, 'upper', 1));
%! myassert (size(Q), size(A));
%! myassert (Q, A);

%!test
%! n = 10;
%! A = tril(ones(n));
%! [Q, opt] = trifactor (A);
%! %Q, A  % DEBUG
%! myassert (strncmp(opt.type, 'triangular', 1));
%! myassert (strncmp(opt.uplow, 'lower', 1));
%! myassert (size(Q), size(A));

%!test
%! n = 10;
%! A = gallery('minij', n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'positive-definite', 1));
%! myassert (strncmp(opt.uplow, 'upper', 1));
%! myassert (size(Q), size(A));

%!test
%! n = 10;
%! A = gallery('minij', n);
%! [Q, opt] = trifactor (A, struct('uplow','lower'));
%! myassert (strncmp(opt.type, 'positive-definite', 1));
%! myassert (strncmp(opt.uplow, 'lower', 1));
%! myassert (size(Q), size(A));

%!test
%! n = 10;
%! A = gallery('minij', n) - 10*eye(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'symmetric', 1));
%! myassert (strncmp(opt.uplow, 'upper', 1));
%! myassert (size(Q), size(A));

%!test
%! n = 10;
%! A = gallery('minij', n) - 10*eye(n);
%! [Q, opt] = trifactor (A, struct('uplow','lower'));
%! myassert (strncmp(opt.type, 'symmetric', 1));
%! myassert (strncmp(opt.uplow, 'lower', 1));
%! myassert (size(Q), size(A));

%!test
%! n = 10;
%! A = rand(n);
%! [Q, opt] = trifactor (A);
%! myassert (strncmp(opt.type, 'general', 1));
%! myassert (isfield(opt, 'Q2'));
%! myassert (size(Q), size(A));


%!test
%! % ask for a specific matrix type:
%! A = rand(1);  % this could be _any_ type.
%! for uplow = {'upper', 'lower'};  uplow = uplow{:};
%! for type = {'diagonal', 'triangular', 'positive-definite', 'symmetric', 'general'},  type = type{:};
%!     [Q, opt] = trifactor (A, struct('type',type, 'uplow',uplow));
%!     myassert (strncmp(opt.type, type, 1));
%!     myassert (strncmp(opt.uplow, uplow, 1) || any(strncmp(opt.type,  {'diagonal', 'general'}, 1)));
%! end
%! end

