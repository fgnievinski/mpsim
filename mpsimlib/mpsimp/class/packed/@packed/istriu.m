function answer = istriu (A)
    if istri_type (A) && isup(A)
        answer = true;
        return;
    end
        
    answer = istriu(full(A));
end

%!error
%! lasterr ('', '');
%! istriu (packed, 1)

%!test
%! % istriu ()
%! s = lasterror;
%! myassert (strendi('TooManyInputs', s.identifier));

%!error
%! lasterr ('', '');
%! [a, b] = istriu (packed)

%!test
%! % istriu ()
%! s = lasterror;
%! myassert (strendi('TooManyOutputs', s.identifier));

%!test
%! myassert (istriu (packed(ones(3), 'tri', 'u')));

%!test
%! % istriu ()
%! do_test_blank_diag_tri_sym (true);

