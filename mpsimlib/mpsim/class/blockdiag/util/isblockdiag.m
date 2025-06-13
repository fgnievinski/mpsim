function answer = isblockdiag(A)
    answer = isa(A, 'blockdiag');
end

%!test
%! A = blockdiag;
%! myassert (isblockdiag(A));

%!test
%! A = 0;
%! myassert (~isblockdiag(A));

%!test
%! A = sparse(0);
%! myassert (~isblockdiag(A));

%!test
%! A = cell(1);
%! myassert (~isblockdiag(A));

