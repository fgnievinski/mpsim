function [s, m, n, clas, uplow] = full_tricond_check_in (A_norm, Q, Q2, uplow)
    if (nargin < 4) || isempty(uplow),  uplow = 'U';  end
    check_int = true;
    check_square = true;
    if isnan(Q2),  check_int = false;  end
    if (nargin < 4) || all(isnan(uplow)),  check_square = false;  end
    [m, n, o] = size(Q);
    clas = class(Q);
    s = [];
    if ~isreal(A_norm) || ~isreal(Q)
        s.identifier = 'trilin:tricond:complexNotSupported';
        s.message = 'Complex numbers are not supported.';
        return;
    end
    if check_square && ~any(strcmpi(uplow(1), {'U','L'}))
        s.identifier = 'trilin:tricond:UplowBad';
        s.message = sprintf('Bad uplow value "%s".', char(uplow));
        return;
    end
    if ~isscalar(A_norm)
        s.identifier = 'trilin:tricond:nonScalar';
        s.message = 'First input must be a scalar.';       
        return;
    end
    if (o > 1)
        s.identifier = 'trilin:tricond:inputsMustBe2D';
        s.message = 'Arguments must be 2-D.';
        return;
    end
    if ~strcmp(class(A_norm), clas)
        s.identifier = 'trilin:trisolve:diffClass';
        s.message = 'Matrices must be of the same class.';
        return;
    end
    if ~any(strcmp(clas, {'double','single'}))
        s.identifier = 'trilin:tricond:nonFloatNotSupported';
        s.message = 'Only double or single precision are supported.';
        return;
    end
    if check_int && ~isinteger(Q2)
        s.identifier = 'trilin:tricond:nonInt';
        s.message = 'Third argument must be integer.';
        return;
    end
    if check_int && (numel(Q2) ~= min(size(Q)))
        s.identifier = 'trilin:tricond:badSize';
        s.message = 'Third argument has wrong size.';
        return;
    end
    if check_square && (m ~= n)
        s.identifier = 'trilin:tricond:square';
        s.message = 'Second argument must be square.';
        return;
    end
end

%!test
%! s = full_tricond_check_in (1, eye(2), eye(2,1, 'int8'), 'u');
%! myassert (isempty(s));

%!test
%! s = full_tricond_check_in (1, complex(eye(2)), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:tricond:complexNotSupported');

%!test
%! s = full_tricond_check_in (1, eye(2), eye(2,1, 'int8'), 'WRONG');
%! myassert (s.identifier, 'trilin:tricond:UplowBad');

%!test
%! s = full_tricond_check_in (cast(1, 'int8'), eye(2,2, 'int8'), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:tricond:nonFloatNotSupported');

%!test
%! s = full_tricond_check_in (1, eye(2,2, 'int8'), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_tricond_check_in (cast(1, 'int8'), eye(2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_tricond_check_in (1, eye(2,2, 'single'), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_tricond_check_in (cast(1, 'single'), eye(2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_tricond_check_in (1, ones(2,2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:tricond:inputsMustBe2D');

%!test
%! s = full_tricond_check_in ([1 1], ones(2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:tricond:nonScalar');

%!test
%! s = full_tricond_check_in (1, eye(3,2), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:tricond:square');

%!test
%! % non-square although empty still yields error.
%! s = full_tricond_check_in (1, eye(0,2), eye(0,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:tricond:square');

%!test
%! s = full_tricond_check_in (1, eye(2), eye(2,1));
%! myassert (s.identifier, 'trilin:tricond:nonInt');

%!test
%! s = full_tricond_check_in (1, eye(2), eye(3,1, 'int8'));
%! myassert (s.identifier, 'trilin:tricond:badSize');

%!test
%! % non-integer although empty still yields error.
%! s = full_tricond_check_in (1, eye(0), eye(0));
%! myassert (s.identifier, 'trilin:tricond:nonInt');

