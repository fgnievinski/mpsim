function answer = istril (A)
    if istri_type (A) && islow(A)
        answer = true;
        return;
    end

    answer = istril(full(A));
end

%!error
%! lasterr ('', '');
%! istril (packed, 1)

%!test
%! % istril ()
%! s = lasterror;
%! myassert (strendi('TooManyInputs', s.identifier));

%!error
%! lasterr ('', '');
%! [a, b] = istril (packed)

%!test
%! % istril ()
%! s = lasterror;
%! myassert (strendi('TooManyOutputs', s.identifier));

%!test
%! myassert (istril (packed(ones(3), 'tri', 'l')));

%!test
%! % istril ()
%! do_test_blank_diag_tri_sym (true);

