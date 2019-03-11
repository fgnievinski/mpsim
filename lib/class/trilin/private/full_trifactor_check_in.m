function [s, m, n, clas, uplow] = full_trifactor_check_in (A, uplow)
    check_square = true;
    if (nargin < 2) || isempty(uplow),  uplow = 'U';  check_square = false;  end
    [m, n, o] = size(A);
    clas = class(A);
    s = [];
    if ~isreal(A)
        s.identifier = 'trilin:trifactor:complexNotSupported';
        s.message = 'Complex numbers are not supported.';
        return;
    end
    if ~any(strcmpi(uplow(1), {'U','L'}))
        s.identifier = 'trilin:trifactor:UplowBad';
        s.message = sprintf('Bad uplow value "%s".', char(uplow));
        return;
    end
    if (o > 1)
        s.identifier = 'trilin:trifactor:inputsMustBe2D';
        s.message = 'Input argument must be 2-D.';
        return;
    end
    if ~any(strcmp(clas, {'double','single'}))
        s.identifier = 'trilin:trifactor:nonFloatNotSupported';
        s.message = 'Only double or single precision are supported.';
        return;
    end
    if check_square && (m ~= n)
        s.identifier = 'trilin:trifactor:square';
        s.message = 'Matrix must be square.';
    end
end

%!test
%! s = full_trifactor_check_in (eye(2), 'u');
%! myassert (isempty(s));

%!test
%! s = full_trifactor_check_in (complex(eye(2)));
%! myassert (s.identifier, 'trilin:trifactor:complexNotSupported');

%!test
%! s = full_trifactor_check_in (eye(2), 'WRONG');
%! myassert (s.identifier, 'trilin:trifactor:UplowBad');

%!test
%! s = full_trifactor_check_in (true(2));
%! myassert (s.identifier, 'trilin:trifactor:nonFloatNotSupported');

%!test
%! s = full_trifactor_check_in (repmat(ones(2), [1,1,2]));
%! myassert (s.identifier, 'trilin:trifactor:inputsMustBe2D');

%!test
%! s = full_trifactor_check_in (ones(3,2));
%! myassert (isempty(s));

%!test
%! s = full_trifactor_check_in (ones(3,2), 'u');
%! myassert (s.identifier, 'trilin:trifactor:square');

%!test
%! % non-square although empty still yields error.
%! s = full_trifactor_check_in (ones(0,2), 'u');
%! myassert (s.identifier, 'trilin:trifactor:square');

