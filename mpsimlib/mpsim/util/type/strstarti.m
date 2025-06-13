function answer = strstarti (str1, str2, case_sensitive)
    if (nargin < 3) || isempty(case_sensitive),  case_sensitive = false;  end
    mystrncmp = @strncmpi;  if case_sensitive,  mystrncmp = @strncmp;  end
    if ~iscell(str1)
        answer = mystrncmp(str1, str2, numel(str1));
        return;
    end    
    if ~iscell(str2),  str2 = {str2};  end
    ns1 = cellfun(@numel, str1);
    n = unique(ns1);
    if isscalar(n)
        answer = mystrncmp(str1, str2, n);
        return;
    end
    N1 = numel(str1);
    N2 = numel(str2);
    if (N2 == 1),  str2 = repmat(str2, [N1 1]);  N2 = N1;  end
    if (N2 ~= N1)
        error('MATLAB:strcmp:InputsSizeMismatch', ...
            'Inputs must be the same size or either one can be a scalar.');
    end
    str2 = arrayfun2(@(i) str2{i}(1:min(ns1(i),end)), 1:N1);
    answer = arrayfun(@(i) mystrncmp(str1{i}, str2{i}, ns1(i)), 1:N1);
end

%!test
%! myassert(strstarti('haha', 'haha/private'));
%! myassert(~strstarti('hahablah', 'haha/private2'));
%! myassert(~strstarti('packed:rcond:complexNotSupported', ...
%!     'packed:chol:complexNotSupported'));
%! out = strstarti('haha', {'haha/private', 'blah/private', ''});
%! myassert(out, [true, false, false])
%! out = strstarti({'haha','haha','haha'}, {'haha/private','blah/private',''});
%! myassert(out, [true, false, false])

