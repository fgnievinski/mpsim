function [ind, ind1, ind2, ind3, ind4] = get_border_ind (grid, n)
    if (nargin < 2),  n = 1;  end
    n = ceil(n);
    ind_all = reshape(1:numel(grid), size(grid));
    ind1 = ind_all(:,1:n);
    ind2 = ind_all(1:n,:);
    ind3 = ind_all(:,end-n+1:end);
    ind4 = ind_all(end-n+1:end,:);
    %whos ind  % DEBUG
    ind = [ind1(:); ind2(:); ind3(:); ind4(:)];
    ind = unique(ind);
end

%!test
%! ind = get_border_ind(rand(2,2));
%! myassert(ind, (1:4)')

%!test
%! ind = get_border_ind(rand(3,3));
%! myassert(ind, setdiff((1:9)', 5))

%!test
%! ind = get_border_ind(rand(3,4));
%! myassert(ind, setdiff((1:12)', [5; 8]))

%!test
%! ind = get_border_ind(rand(4,4));
%! myassert(ind, setdiff((1:16)', [6 7 10 11]'))

%!test
%! ind = get_border_ind(rand(4,4), 2);
%! myassert(ind, (1:16)')
