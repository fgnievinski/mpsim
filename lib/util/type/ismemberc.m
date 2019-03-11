function tf = ismemberc (a, S)
    assert(~iscell(a))
    tf = cellfun(@(s) ismember(a, s), S);
end

%!test
%! myassert(ismemberc('a', {{'a'}, {'b'}, {'a','b'}}), [true false true])
