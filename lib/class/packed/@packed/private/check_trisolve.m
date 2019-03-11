function s = check_trisolve (B, Q)
    s = [];
    if ispacked(B)
        s.identifier = 'packed:check_trisolve:badInput';
        s.message = 'First parameter should not be in packed storage.';
        return;
    end
    if ~ispacked(Q)
        s.identifier = 'packed:check_trisolve:badInput';
        s.message = 'Second parameter should be a matrix in packed storage.';
        return;
    end
    if ~istri_type (Q)
        s.identifier = 'packed:check_trisolve:badInput';
        s.message = 'First parameter should be a triangular matrix.';
        return;
    end
    if ~isreal(B) || ~isreal(Q)
        s.identifier = 'packed:check_trisolve:complexNotSupported';
        s.message = 'Complex numbers are not supported.';
        return;
    end
end

%!test
%! s = check_trisolve (packed(eye(2)), eye(2));
%! myassert (s.identifier, 'packed:check_trisolve:badInput');

%!test
%! s = check_trisolve (packed([1 1 1], 'sym', 'u'), eye(2));
%! myassert (s.identifier, 'packed:check_trisolve:badInput');

%!test
%! s = check_trisolve (packed(eye(2)), packed([1 1 1], 'tri', 'u'));
%! myassert (s.identifier, 'packed:check_trisolve:badInput');

%!test
%! s = check_trisolve (eye(2), packed(complex([1 1 1]), 'tri', 'u'));
%! myassert (s.identifier, 'packed:check_trisolve:complexNotSupported');

%!test
%! s = check_trisolve (eye(2), packed([1 1 1], 'tri', 'u'));
%! myassert (isempty(s));

