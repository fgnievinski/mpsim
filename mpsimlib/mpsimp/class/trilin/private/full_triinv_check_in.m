function [s, m, n, clas, uplow] = full_triinv_check_in (Q, Q2, uplow)
    if (nargin < 3) || isempty(uplow),  uplow = 'U';  end
    check_int = true;
    check_square = true;
    if isnan(Q2),  check_int = false;  end
    if (nargin < 3) || all(isnan(uplow)),  check_square = false;  end
    [m, n, o] = size(Q);
    clas = class(Q);
    s = [];
    if ~isreal(Q)
        s.identifier = 'trilin:triinv:complexNotSupported';
        s.message = 'Complex numbers are not supported.';
        return;
    end
    if check_square && ~any(strcmpi(uplow(1), {'U','L'}))
        s.identifier = 'trilin:triinv:UplowBad';
        s.message = sprintf('Bad uplow value "%s".', char(uplow));
        return;
    end
    if (o > 1)
        s.identifier = 'trilin:triinv:inputsMustBe2D';
        s.message = 'Arguments must be 2-D.';
        return;
    end
    if ~any(strcmp(clas, {'double','single'}))
        s.identifier = 'trilin:triinv:nonFloatNotSupported';
        s.message = 'Only double or single precision are supported.';
        return;
    end
    if check_int && ~isinteger(Q2)
        s.identifier = 'trilin:triinv:nonInt';
        s.message = 'Third argument must be integer.';
        return;
    end
    if check_int && (numel(Q2) ~= min(size(Q)))
        s.identifier = 'trilin:triinv:badSize';
        s.message = 'Third argument has wrong size.';
        return;
    end
    if check_square && (m ~= n)
        s.identifier = 'trilin:triinv:square';
        s.message = 'Second argument must be square.';
        return;
    end
end

%!test
%! s = full_triinv_check_in (eye(2), eye(2,1, 'int8'), 'u');
%! myassert (isempty(s));

%!test
%! s = full_triinv_check_in (complex(eye(2)), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:triinv:complexNotSupported');

%!test
%! s = full_triinv_check_in (eye(2), eye(2,1, 'int8'), 'WRONG');
%! myassert (s.identifier, 'trilin:triinv:UplowBad');

%!test
%! s = full_triinv_check_in (eye(2,2, 'int8'), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:triinv:nonFloatNotSupported');

%!test
%! s = full_triinv_check_in (ones(2,2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:triinv:inputsMustBe2D');

%!test
%! s = full_triinv_check_in (eye(3,2), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:triinv:square');

%!test
%! % non-square although empty still yields error.
%! s = full_triinv_check_in (eye(0,2), eye(0,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:triinv:square');

%!test
%! s = full_triinv_check_in (eye(2), eye(2,1));
%! myassert (s.identifier, 'trilin:triinv:nonInt');

%!test
%! s = full_triinv_check_in (eye(2), eye(3,1, 'int8'));
%! myassert (s.identifier, 'trilin:triinv:badSize');

%!test
%! % non-integer although empty still yields error.
%! s = full_triinv_check_in (eye(0), eye(0));
%! myassert (s.identifier, 'trilin:triinv:nonInt');

