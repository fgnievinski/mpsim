function [answer, c] = isfieldempty (a, b, varargin)
    if iscell(b)
        [answer, c] = isfieldempty (a, b{:}, varargin{:});
        return
    end
    answer = ~isfield(a, b) || isempty(a.(b));
    c = [];
    if answer || ((nargout < 2) && (nargin < 3)),  return;  end
    c = a.(b);
    if (nargin < 3),  return;  end
    [answer, c] = isfieldempty (c, varargin{:});
end

%!test
%! assert( isfieldempty(struct('b',[]),'b'))
%! assert(~isfieldempty(struct('b', 0),'b'))
%! assert( isfieldempty(struct('b', 0),'c'))
%! assert( isfieldempty(struct('b',[]),'c'))
%! a = struct('bb',struct('c',pi, 'd',[]));
%! assert(~isfieldempty(a, 'bb'))
%! assert(~isfieldempty(a, 'bb', 'c'))
%! assert( isfieldempty(a, 'bb', 'd'))
%! assert( isfieldempty(a, 'bb', 'e'))
%! assert( isfieldempty(a, {'bb', 'e'}))
%! assert( isfieldempty(a, {'bb', 'e'}, 'd'))

