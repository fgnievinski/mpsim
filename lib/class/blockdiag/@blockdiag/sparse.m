function out = sparse (in)
    out = unblockdiag (in);
end

%!test
%! in = blockdiag(sparse(1), sparse(2));
%! out = full(in);
%! out2 = blkdiag(sparse(1), sparse(2));
%! myassert(out2, out)
%! myassert(class(out2), class(out))

