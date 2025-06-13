function [dist_unique, dist_unique_count] = unique_eps (dist)
    tol = 2*eps;
    if (nargout > 1)
        [dist_unique, dist_unique_count] = unique_tol (dist, tol);
    else
        dist_unique = unique_tol (dist, tol);
    end
return

%!test
%! dist = [1 2 3 4 4 5 5+eps 6 7];
%! dist_unique = [1 2 3 4 5 6 7];
%! myassert (dist_unique, unique_eps (dist));

%!test
%! dist = [1 2 3 4 4 5+10*eps 5 6 7];
%! dist_unique = [1 2 3 4 5 5+10*eps 6 7];
%! %unique_eps (dist)
%! myassert (dist_unique, unique_eps (dist));

%!test
%! dist = [5+10*eps 1 2 3 4 4 5 6 7];
%! dist_unique = [1 2 3 4 5 5+10*eps 6 7];
%! %unique_eps (dist)
%! myassert (dist_unique, unique_eps (dist));

%!test
%! dist = [1 2 3 4 4 5 5+eps 5-eps 6 7];
%! dist_unique = [1 2 3 4 5 6 7];
%! dist_count =  [1 1 1 2 3 1 1];
%! [dist_unique_answer, dist_count_answer] = unique_eps (dist);
%! myassert (dist_unique, dist_unique_answer);
%! myassert (dist_count, dist_count_answer);

