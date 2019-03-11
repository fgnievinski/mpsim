function varargout = unique_tol (dist, tol, angular)
    if (nargin < 2) || isempty(tol),  tol = sqrt(eps());  end
    if (nargin < 3) || isempty(angular),  angular = false;  end
    idx = ~isnan(dist);
    [varargout{1:nargout}] = unique_tol_aux (dist(idx), tol, angular);
    if (nargout < 3) || all(idx),  return;  end
    varargout{3} = getel(find(idx), varargout{3});
    varargout{4} = setel(NaN(size(dist)), idx, varargout{4});
    varargout{5} = setel(NaN(size(dist)), idx, varargout{5});
end

%%
function [dist_unique, dist_unique_count, ind, ind2, dist_sort] = unique_tol_aux (dist, tol, angular)
    if isempty(dist)
        dist_unique = [];
        dist_unique_count = [];
        ind = [];
        ind2 = [];
        dist_sort = [];
        return;
    end
    
    %% reshape data:
    myassert (~any(isnan(dist)));
    myassert (isvector(dist));
    dim = finddim(dist);
    if (dim==2),  mytranspose = @transpose;  else  mytranspose = @itself;  end
    dist = mytranspose(dist);
    N = numel(dist);
    %tol  % DEBUG

    %% get unique values: (the first value occurring in a given cluster)
    dist_sort = dist;
    if ~issorted(dist)
        dist_sort = sort(dist);
        if (nargout > 2)
            warning('MATLAB:unique_tol:unsorted', ['Unsorted input; '...
              'output indices will correspond to sorted input.']);
        end
    end
    if angular
        dist_diff = angle_diff(dist_sort);
    else
        dist_diff = diff(dist_sort);
    end
    dist_diff = [Inf; dist_diff];
    dist_unique_idx = (abs(dist_diff) > tol);
    dist_unique = dist_sort(dist_unique_idx);
    %dist_unique  % DEBUG
    if (nargout < 2)
        dist_unique = mytranspose(dist_unique);
        return;
    end
    
    %% number of repeated values per unique value:
    % it can be found in the difference between positions of
    % sucessive unique values:
    temp = [find(dist_unique_idx); length(dist_sort)+1];
    %temp  % DEBUG
    dist_unique_count = diff(temp);
%     if angular
%         %dist_unique_count = angle_diff(temp);  % WRONG!
%         dist_unique_count = diff(temp);
%     else
%         dist_unique_count = diff(temp);
%     end
    %[sum(dist_unique_count), length(dist_sort)]  % DEBUG
    myassert (sum(dist_unique_count) == length(dist_sort));
    if (nargout < 3)
        dist_unique = mytranspose(dist_unique);
        dist_unique_count = mytranspose(dist_unique_count);
        return;
    end
    
    %% index:
    ind = find(dist_unique_idx);
    ind2 = NaN(N,1);
    inde = N;
    for i=numel(ind):-1:1
        indi = ind(i);
        indi2 = indi:inde;
        ind2(indi2) = i;
        inde = indi-1;
    end
    %ind2 = ind2(ind_sort_inv);
    %ind = find(dist_unique_idx(ind_sort_inv));    
    
    %%
    dist_unique = mytranspose(dist_unique);
    dist_unique_count = mytranspose(dist_unique_count);
    ind = mytranspose(ind);
    ind2 = mytranspose(ind2);
end

%%
%!test
%! tol = 1;
%! dist  = [  0 10 11 NaN 12 20 21 22 NaN 30];
%! ind2 =  [  1  2  2 NaN  2  3  3  3 NaN  4];
%! dist_unique = [0 10 20 30];
%! dist_unique_count = [1 3 3 1];
%! ind = [1 2 6 10];
%! [dist_unique_answer, dist_unique_count_answer, ind_answer, ind2_answer] = unique_tol(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (dist_unique_count, dist_unique_count_answer);
%! myassert (ind, ind_answer);
%! %[ind, ind_answer]  % DEBUG
%! myassert (ind2, ind2_answer);

%!test
%! tol = 1;
%! dist  = [10 11 12 13 20 21 22];
%! %diff = [Inf 1  1  1  7  1  1];
%! %idx  = [ 1  0  0  0  1  0  0];
%! ind2  = [ 1  1  1  1  2  2  2];
%! dist_unique = [10 20];
%! dist_unique_count = [4 3];
%! ind = [1 5];
%! [dist_unique_answer, dist_unique_count_answer, ind_answer, ind2_answer] = unique_tol(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (dist_unique_count, dist_unique_count_answer);
%! myassert (ind, ind_answer);
%! %[ind2; ind2_answer]  % DEBUG
%! myassert (ind2, ind2_answer);

%!test
%! tol = 1;
%! dist  = [  0 10 11 12 13 20 21 22];
%! %diff = [Inf 10  1  1  1  7  1  1];
%! %idx2 = [  1  1  0  0  0  1  0  0];
%! ind2 =  [  1  2  2  2  2  3  3  3];
%! dist_unique = [0 10 20];
%! dist_unique_count = [1 4 3];
%! ind = [1 2 6];
%! [dist_unique_answer, dist_unique_count_answer, ind_answer, ind2_answer] = unique_tol(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (dist_unique_count, dist_unique_count_answer);
%! myassert (ind, ind_answer);
%! myassert (ind2, ind2_answer);

%!test
%! tol = 0;
%! dist = [0 0 0 0 1 1 1];
%! ind2 = [1 1 1 1 2 2 2];
%! dist_unique = [0 1];
%! dist_unique_count = [4 3];
%! ind = [1 5];
%! [dist_unique_answer, dist_unique_count_answer, ind_answer, ind2_answer] = unique_tol(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (dist_unique_count, dist_unique_count_answer);
%! myassert (ind, ind_answer);
%! myassert (ind2, ind2_answer);
