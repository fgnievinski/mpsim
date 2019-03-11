function s = renfields (s, n1, n2, varargin)
%RENFIELDS  Rename structure field.
    if iscell(n1) && iscell(n2)
        assert(numel(n1) == numel(n2))
        n = [n1(:) n2(:)];
        n = n';
        s = renfields(s, n{:});
        return;
    end
    s = renfield (s, n1, n2);
    if (nargin < 4),  return;  end
    s = renfields (s, varargin{:});
end

%!test
%! myassert(renfields(struct('a',[], 'c',[]), 'a','b', 'c','d'), struct('b',[], 'd',[]))
%! myassert(renfields(struct('a',[], 'c',[]), {'a','c'}, {'b','d'}), struct('b',[], 'd',[]))
