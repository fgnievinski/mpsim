function answer = is_contiguous_vector (x)
% see also: is_contiguous, is_regularly_spaced.
    answer = is_contiguous_indices (x);
end

function answer = is_contiguous_indices (x)
    if (numel(x) < 2),  answer = true;  return;  end  % if isempty(x) || isscalar
    answer = all(abs(diff(x)) == 1);
end

%!test
%! myassert(is_contiguous_vector(1:10))
%! myassert(is_contiguous_vector(10:-1:1))
%! myassert(~is_contiguous_vector([1 2 5]))
%! myassert(~is_contiguous_vector(0:0.5:10))
