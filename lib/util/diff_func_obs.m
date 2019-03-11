function answer = diff_func_obs (f, pt, h)
    if (nargin < 3),  h = [];  end
    [num_pts, num_coords] = size(pt);
    temp = diff_func2 (f, pt, h);
    answer = reshape(temp', [], num_coords, num_pts);
    % we assume one observation point is independent of all other points.
end

%!shared
%! n = ceil(10*rand);
%! pt = rand(n, 3);

%!test
%! % only one equation type
%! f = @(pt) sum(pt, 2);
%! answer = ones(1, 3, n);
%! answer2 = diff_func_obs (f, pt);
%! %answer, answer2  % DEBUG
%! myassert(answer, answer2, -sqrt(eps));

%!test
%! % three independent equation types
%! f = @(pt) sin(pt);
%! temp = cos(pt);
%! answer = zeros(3,3,n);
%! for k=1:n,  answer(:,:,k) = diag(temp(k,:));  end
%! answer2 = diff_func_obs (f, pt);
%! %answer, answer2  % DEBUG
%! myassert(answer, answer2, -sqrt(eps));

%!test
%! % more than three, dependent, equation types
%! f = @(pt) [...
%!     (1 * pt(:,1) + 2 * pt(:,2) + 3 * pt(:,3)), ...
%!     (4 * pt(:,1) + 5 * pt(:,2) + 6 * pt(:,3)), ...
%!     (7 * pt(:,1) + 8 * pt(:,2) + 9 * pt(:,3)), ...
%!     (1 * pt(:,1) + 1 * pt(:,2) + 1 * pt(:,3)), ...
%! ];
%! answer = repmat([1 2 3; 4 5 6; 7 8 9; 1 1 1], [1,1,n]);
%! answer2 = diff_func_obs (f, pt);
%! %answer, answer2  % DEBUG
%! myassert(answer, answer2, -sqrt(eps));

%!test
%! % more than three, dependent, equation types 
%! % and fewer than three coordinates per point
%! pt(:,3) = [];
%! f = @(pt) [...
%!     (1 * pt(:,1) + 2 * pt(:,2)), ...
%!     (4 * pt(:,1) + 5 * pt(:,2)), ...
%!     (7 * pt(:,1) + 8 * pt(:,2)), ...
%!     (1 * pt(:,1) + 1 * pt(:,2)), ...
%! ];
%! answer = repmat([1 2; 4 5; 7 8; 1 1], [1,1,n]);
%! answer2 = diff_func_obs (f, pt);
%! %answer, answer2  % DEBUG
%! myassert(answer, answer2, -sqrt(eps));

