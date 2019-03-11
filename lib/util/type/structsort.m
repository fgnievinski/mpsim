function [pt, ind] = structsort(pt, field_sort, field, unique_only)
    if (nargin < 4) || isempty(unique_only),  unique_only = false;  end
    myassert(all(isfield(pt, field)));
    if unique_only
        [ignore, ind] = unique(pt.(field_sort)); %#ok<ASGLU>
    else
        [ignore, ind] = sort(pt.(field_sort)); %#ok<ASGLU>
    end
    for i=1:length(field)
        %i  % DEBUG
        pt.(field{i}) = pt.(field{i})(ind, :);
    end
end

