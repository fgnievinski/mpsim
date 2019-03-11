function result = structempty(field, value)
    if (nargin == 0),  field = [];  end
    result = [];
    if (nargin < 2),  value = [];  end
    for i=1:length(field)
        result.(field{i}) = value;
    end
end

%!test
%! myassert(isempty(structempty()))

%!test
%! myassert(isempty(structempty([])))

%!test
%! field = {'a','b'};
%! c = structempty(field);
%! myassert(all(isfield(c, field)))

%!test
%! field = {'a','b'};
%! value = rand;
%! c = structempty(field, value);
%! myassert(all(isfield(c, field)))

