function [s, B_m, B_n, Q_m, Q_n, clas, uplow, trans] = full_trisolve_check_in (B, Q, Q2, uplow, trans)
    if (nargin < 4) || isempty(uplow),  uplow = 'U';  end
    if (nargin < 5) || isempty(trans),  trans = 'N';  end
    check_int = true;
    check_square = true;
    check_trans = true;
    if isnan(Q2),  check_int = false;  end
    if (nargin < 4) || all(isnan(uplow)),  check_square = false;  end
    if (nargin < 5) || all(isnan(trans)),  check_trans = false;  end
    [B_m, B_n, B_o] = size(B);
    [Q_m, Q_n, Q_o] = size(Q);
    B_class = class(B);
    Q_class = class(Q);
    s = [];
    if ~isreal(B) || ~isreal(Q)
        s.identifier = 'trilin:trisolve:complexNotSupported';
        s.message = 'Complex numbers are not supported.';
        return;
    end
    if check_square && ~any(strcmpi(uplow(1), {'U','L'}))
        s.identifier = 'trilin:trisolve:UplowBad';
        s.message = sprintf('Bad uplow value "%s".', char(uplow));
        return;
    end
    if check_trans && ~any(strcmpi(trans(1), {'N','T'}))
        s.identifier = 'trilin:trisolve:TransBad';
        s.message = sprintf('Bad trans value "%s".', char(trans));
        return;
    end
    if (B_o > 1) || (Q_o > 1)
        s.identifier = 'trilin:trisolve:inputsMustBe2D';
        s.message = 'Arguments must be 2-D.';
        return;
    end
    if ~strcmp(Q_class, B_class)
        s.identifier = 'trilin:trisolve:diffClass';
        s.message = 'Matrices must be of the same class.';
        return;
    end
    clas = B_class;
    if ~any(strcmp(clas, {'double','single'}))
        s.identifier = 'trilin:trisolve:nonFloatNotSupported';
        s.message = 'Only double or single precision are supported.';
        return;
    end
    if check_int && ~isinteger(Q2)
        s.identifier = 'trilin:trisolve:nonInt';
        s.message = 'Third argument must be integer.';
        return;
    end
    if check_int && (numel(Q2) ~= min(size(Q)))
        s.identifier = 'trilin:trisolve:badSize';
        s.message = 'Third argument has wrong size.';
        return;
    end
    if check_square && (Q_m ~= Q_n)
        s.identifier = 'trilin:trisolve:square';
        s.message = 'Second argument must be square.';
        return;
    end
    if (B_m ~= Q_m)
        s.identifier = 'trilin:trisolve:innerdim';
        s.message = 'Inner matrix dimensions must agree.';
        return;
    end
end

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(2), eye(2,1, 'int8'), 'u');
%! myassert (isempty(s));

%!test
%! s = full_trisolve_check_in (complex(zeros(2,1)), eye(2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:complexNotSupported');

%!test
%! s = full_trisolve_check_in (zeros(2,1), complex(eye(2)), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:complexNotSupported');

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(2), eye(2,1, 'int8'), 'WRONG');
%! myassert (s.identifier, 'trilin:trisolve:UplowBad');

%!test
%! s = full_trisolve_check_in (zeros(2,1, 'int8'), eye(2,2, 'int8'), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:nonFloatNotSupported');

%!test
%! s = full_trisolve_check_in (zeros(2,1,2), eye(2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:inputsMustBe2D');

%!test
%! s = full_trisolve_check_in (zeros(2,1), ones(2,2,2), eye(2,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:inputsMustBe2D');

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(3,2), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:trisolve:square');

%!test
%! % non-square although empty still yields error.
%! s = full_trisolve_check_in (zeros(0,1), eye(0,2), eye(0,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:trisolve:square');

%!test
%! s = full_trisolve_check_in (single(zeros(2,1)), double(eye(2)), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_trisolve_check_in (double(zeros(2,1)), single(eye(2)), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:trisolve:diffClass');

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(2), eye(2,1));
%! myassert (s.identifier, 'trilin:trisolve:nonInt');

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(2), eye(3,1, 'int8'));
%! myassert (s.identifier, 'trilin:trisolve:badSize');

%!test
%! % non-integer although empty still yields error.
%! s = full_trisolve_check_in (zeros(0,0), eye(0), eye(0));
%! myassert (s.identifier, 'trilin:trisolve:nonInt');

%!test
%! s = full_trisolve_check_in (zeros(3,1), eye(2), eye(2,1, 'int8'), 'u');
%! myassert (s.identifier, 'trilin:trisolve:innerdim');

%!test
%! % NRHS > 1 is okay, of course:
%! s = full_trisolve_check_in (zeros(2,3), eye(2), eye(2,1, 'int8'), 'u');
%! myassert(isempty(s))

%!test
%! s = full_trisolve_check_in (zeros(2,1), eye(2), eye(2,1, 'int8'), 'u', 'WRONG');
%! myassert (s.identifier, 'trilin:trisolve:TransBad');

