function answer = issym (A)
    if issym_type(A)
        answer = true;
        return;
    end
    
    answer = issym(full(A));
end

%!error
%! lasterr ('', '');
%! issym (packed, 1)

%!test
%! % issym ()
%! s = lasterror;
%! myassert (strendi('TooManyInputs', s.identifier));

%!error
%! lasterr ('', '');
%! [a, b] = issym (packed)

%!test
%! % issym ()
%! s = lasterror;
%! myassert (strendi('TooManyOutputs', s.identifier));

%!test
%! % issym ()
%! do_test_blank_diag_tri_sym (true);

