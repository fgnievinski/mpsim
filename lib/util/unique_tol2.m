function [dist_unique2, max_abs_diff, ind, ind2, dist_sort] = unique_tol2 (dist, tol, robustify, angular)
    if (nargin < 3) || isempty(robustify),  robustify = true;  end
    if (nargin < 4) || isempty(angular),  angular = false;  end
    
    if (nargout < 3),  s = warning('off', 'MATLAB:unique_tol:unsorted');  end
    [dist_unique, dist_unique_count, ind, ind2, dist_sort] = unique_tol (dist, tol, angular); %#ok<ASGLU>
    if (nargout < 3),  warning(s);  end
    siz = size(dist_unique);
    
        if ~angular && ~robustify,  fnc = @mean;
    elseif ~angular &&  robustify,  fnc = @median;
    elseif  angular && ~robustify,  fnc = @angle_mean;
    elseif  angular &&  robustify,  fnc = @angle_median;
    end
    if ~angular
        fnc2 = @(in) max(abs(in - fnc(in)));
    else
        fnc2 = @(in) max(abs(angle_diff(in, fnc(in))));
    end
    fncs = {fnc, fnc2};
    
    %dist2 = dist;  % WRONG!
    dist2 = dist_sort;
    dist2 = dist2(:);
    ind2 = ind2(:);
    idx = ~isnan(ind2);
    %[dist_unique2, max_abs_diff] = grpstats(dist_which, ind2, fncs);  % WRONG!
    %[dist_unique2, max_abs_diff] = grpstatsall(dist2(idx), ind2(idx), ind, fncs);  % WRONG!
    [dist_unique2, max_abs_diff] = grpstatsall(dist2(idx), ind2(idx), (1:numel(ind))', fncs);
    dist_unique2 = reshape(dist_unique2, siz);
    max_abs_diff = reshape(max_abs_diff, siz);
end

%!test
%! tol = 1;
%! dist  = [10 11 12 13 20 21 22];
%! dist_unique = [11.5 21.0];
%! max_abs_diff = [1.5 1.0];
%! [dist_unique_answer, max_abs_diff_answer] = unique_tol2(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (max_abs_diff, max_abs_diff_answer);

%!test
%! tol = 1;
%! dist  = [0 10 11 12 13 20 21 22];
%! dist_unique = [0 11.5 21];
%! max_abs_diff = [0 1.5 1];
%! [dist_unique_answer, max_abs_diff_answer] = unique_tol2(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (max_abs_diff, max_abs_diff_answer);

%!test
%! tol = 0;
%! dist  = [0 0 0 0 1 1 1];
%! dist_unique = [0 1];
%! max_abs_diff = [0 0];
%! [dist_unique_answer, max_abs_diff_answer] = unique_tol2(dist, tol);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (max_abs_diff, max_abs_diff_answer);
