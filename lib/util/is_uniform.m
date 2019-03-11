function answer = is_uniform (x, tol)
    if (numel(x) < 2),  answer = true;  return;  end  % if isempty(x) || isscalar(x)
    if (nargin < 2) || isempty(tol),  tol = 0;  end
    %answer = isscalar(unique_tol(x,tol));  % (correct but slower)
    answer = all(abs(x - x(1)) <= tol);
    %answer = all(x == x(1));  % WRONG! (except when tol=0)
end

%!test
%! % is_uniform()
%! test('is_regularly_spaced')

