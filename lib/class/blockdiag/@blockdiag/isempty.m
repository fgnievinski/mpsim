function answer = isempty(A)
    answer = isempty(cell(A));
end

%!test
%! temp = blockdiag({});
%! myassert(isblockdiag(temp));
%! myassert(isempty(temp));

%!test
%! temp = blockdiag(1, 2);
%! myassert(isblockdiag(temp));
%! myassert(~isempty(temp));

