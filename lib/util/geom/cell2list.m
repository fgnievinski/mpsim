function out = cell2list (in)
    assert(all(cellfun(@iscolumn, in)))
    assert(iscolumn(in))
    in = cellfun2(@double, in);  % otherwise, 'MATLAB:cell2mat:MixedDataTypes'.
    in(:,2) = {NaN};
    in = reshape(transpose(in), [], 1);
    out = cell2mat(in);
end

%!test
%! in = {[1;2]; [3; 4]};
%! out = [1 2 NaN 3 4 NaN]';
%! out2 = cell2list (in);
%! myassert(out2, out)
