function struct = setfields (struct, field, value, varargin)
    struct = setfield(struct, field, value); %#ok<SFLD>
    if (nargin < 4),  return;  end
    struct = setfields (struct, varargin{:});
end

%!test
%! s = struct('a',1, 'b',2);
%! s2= setfields(struct(), 'a',1, 'b',2);
%! %s, s2  % DEBUG
%! myassert(s, s2)

