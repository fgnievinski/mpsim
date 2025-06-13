% Given n, the number of elements in the triangular part
% of a square matrix, returns x, the size of 
% (one of the two equal sides of) the matrix.
% 
% If it is impossible to have a square matrix with 
% n elements in its diagonal part, then x is empty.
function x = get_full_len_by_pkd_len (n)
    myassert (n >= 0);

    x = (-1 + sqrt(1 + 8*n) ) / 2;
    % this formula comes from 
    %   n = (x*x - x) / 2 + x
    % i.e., the number of elements in the triangular part
    % of a square matrix is half of the total number of elements 
    % (x*x) minus the number of elements in the main diagonal
    % (x) (i.e., (x*x - x) / 2), plus the number of elements
    % in the main diagonal.

    if (mod(x, 1) ~= 0)
        x = [];
    end

    %display(x);  % DEBUG
end

%!test
%! for i=1:10
%!     x = round(rand*100);
%!     temp = triu(true(x));
%!     n = sum(temp(:));
%!     myassert (n, (x*x - x) / 2 + x);
%!     myassert (get_full_len_by_pkd_len(n), x);
%! end

%!test
%! for i=1:10
%!     x = round(rand*100);
%!     temp = triu(true(x));
%!     n = sum(temp(:)) + 1;
%!     myassert (isempty(get_full_len_by_pkd_len(n)));
%! end

