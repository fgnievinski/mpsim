function s = structsqueeze(s)
    if isempty(s) && ~iscell(s),  s = struct();  end
    c = struct2cell(s);
    idx = cellfun(@isempty, c);
    if ~any(idx),  return;  end
    f = fieldnames(s);
    s = cell2struct (c(~idx), f(~idx));
end

%!test
%! s = struct('a',1, 'b',[], 'c',2);
%! s2 = struct('a',1, 'c',2);
%! s3 = structsqueeze(s);
%! myassert(s3, s2);

%!test
%! % empty result:
%! s = struct('b',[]);
%! s2 = cell2struct({},{});
%! s3 = structsqueeze(s);
%! myassert(s3, s2);

