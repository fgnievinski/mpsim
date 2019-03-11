function out = unblockdiag (in)
    temp = diag(cell(in));
    out = blkdiag(temp{:});
end

