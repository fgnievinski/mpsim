function tf = ismembercc (A, S)
    if ~iscell(S),  S = {S};  end
    tf = cellfun(@(a) any(ismember(a, S)), A);
end

%!test
%! myassert(ismembercc({{'c'}, {'b'}, {'a','b'}}, {'b','a'}), [false true true])
