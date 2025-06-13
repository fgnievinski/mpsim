function answer = ctranspose (A)
    if ~isreal(A) && issym_type(A)
        error ('packed:ctranspose:notSupported', 'Feature not supported.');
    end
    answer = transpose(A);
end

%!test
%! n = 4;
%! A = packed(rand(n), 'sym');
%! A_full = full(A);
%! myassert (ctranspose(A), ctranspose(A_full));
%! myassert (ctranspose(A), A');

%!error
%! lasterr('', '');
%! n = 4;
%! A = packed(complex(rand(n)), 'sym');
%!     myassert (~isreal(A));
%! ctranspose(A);

%!test
%! % ctranspose ()
%! s = lasterror;
%! myassert (s.identifier, 'packed:ctranspose:notSupported');

%!test
%! n = 4;
%! A = packed(complex(rand(n)), 'tri', 'u');
%!     myassert (~isreal(A));
%! A_full = full(A);
%!     myassert (~isreal(A_full));
%! myassert (ctranspose(A), ctranspose(A_full));
%! myassert (ctranspose(A), A');
%! myassert (~isreal(ctranspose(A)));

