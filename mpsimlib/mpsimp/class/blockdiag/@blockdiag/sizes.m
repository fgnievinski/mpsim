function varargout = sizes (A)
    [varargout{1:nargout}] = sizes(cell(A));
end

%!test
%! temp = blockdiag(1);
%! myassert (isblockdiag(temp));
%! myassert(sizes(temp), {[1, 1]});

%!test
%! temp = blockdiag({[]});
%! myassert (isblockdiag(temp));
%! myassert(sizes(temp), {[0, 0]});

%!test
%! temp = blockdiag({});
%! myassert (isblockdiag(temp));
%! myassert(isempty(sizes(temp)));

%!test
%! temp = blockdiag(1, 1);
%! myassert (isblockdiag(temp));
%! myassert(sizes(temp), {[1,1], [0,0]; [0,0], [1,1]});

%!test
%! temp = blockdiag(ones(2), ones(3));
%! myassert (isblockdiag(temp));
%! myassert(sizes(temp), {[2, 2], [0, 0]; [0,0], [3,3]});

