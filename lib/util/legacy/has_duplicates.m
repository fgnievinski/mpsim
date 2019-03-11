function varargout = has_duplicates (varargin)
    [varargout{1:nargout}] = is_unique (varargin{:});
    varargout{1} = ~varargout{1};
end

%!test
%! assert(~has_duplicates([1 2 3]'))
%! assert(~has_duplicates([1 2 3]))
%! assert( has_duplicates([1 2 2]'))
%! assert( has_duplicates([1 2 2]))

