function answer = scalar(A)
    answer = isscalar(cell(A));
end

%!test
%! temp = blockdiag({});
%! myassert(isblockdiag(temp));
%! myassert(~isscalar(temp));

%!test
%! temp = blockdiag({1});
%! myassert(isblockdiag(temp));
%! myassert(isscalar(temp));

%!test
%! temp = blockdiag({[]});
%! myassert(isblockdiag(temp));
%! myassert(isscalar(temp));

%!test
%! temp = blockdiag(1, 2);
%! myassert(isblockdiag(temp));
%! myassert(~isscalar(temp));

