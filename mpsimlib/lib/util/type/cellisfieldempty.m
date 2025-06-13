function answer = cellisfieldempty (a, fs)
    assert(iscell(fs))
    answer = cellfun(@(f) isfieldempty(a, f), fs);
end

%!test
%! assert(all(cellisfieldempty(struct('b',[], 'a',[]),{'b','a','c'})))
%! assert(all(~cellisfieldempty(struct('b',1, 'a',2),{'b','a'})))
