function out = full (in)
    out = unblockdiag (in);
end

%!test
%! in = blockdiag(1, 2);
%! out = full(in);
%! out2 = blkdiag(1, 2);
%! myassert(out2, out)

