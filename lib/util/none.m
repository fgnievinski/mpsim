function out = none(in, varargin)
    out = ~any(in, varargin{:});
end

%!test
%! myassert(none([false]))
%! myassert(~none([true]))

