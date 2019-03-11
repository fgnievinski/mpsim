function c = dot_all (a, b)
    switch nargin
    case 1
        c = sum(a.^2, 2);
    case 2
        c = sum(bsxfun(@times, a, b), 2);
    end
end

%!shared
%! n = 10 + ceil(10*rand);
%! a = rand(n,3);
%! b = rand(n,3);

%!test
%! % alternative implementation:
%! c  = dot_all  (a, b);
%! c2 = dot_all2 (a, b);
%! c3 = dot_all3 (a, b);
%! %c, c2, c2 - c  % DEBUG
%! myassert(c2, c, eps)
%! myassert(c3, c, eps)
%! function c = dot_all2 (a, b)
%!     myassert (size(a), size(b));
%!     n = size(a, 1);
%!     c = zeros(n, 1);
%!     for i=1:n
%!         c(i) = dot (a(i,:), b(i,:));        
%!     end
%! end
%! function c = dot_all3 (a, b)
%!     [na,ma,pa] = size(a);
%!     [nb,mb,pb] = size(b);
%!     if ( (pa > 1) || (pb > 1) )
%!         c = sum(frontal_times(a, b), 2);
%!         return;
%!     end
%!     assert(ma == mb);
%!     if (na == nb)
%!         c = sum(a .* b, 2);
%!     elseif (na == 1) || (nb == 1)
%!         c = 0;
%!         for i=1:ma
%!             c = c + a(:,i) * b(:,i);
%!         end
%!         % profile -memory on was indicating arrayfun as a memory hog:
%!         %temp = arrayfun(@(i) a(:,i) * b(:,i), 1:ma, ...
%!         %    'UniformOutput',false);
%!         %temp = cell2mat(temp);
%!         %c = sum(temp, 2);
%!     else
%!         error('matlab:dot_all:badSize', 'Bad size.');
%!     end
%! end

%!test
%! c  = dot_all (a);
%! c2 = dot_all (a, a);
%! %c, c2, c2 - c  % DEBUG
%! myassert(c2, c, eps)

%!test
%! % one point times multiple points.
%! b = repmat(b(1,:), n,1);
%! c  = dot_all (a, b(1,:));
%! c2 = dot_all (a, b);
%! %n, c, c2, c2 - c  % DEBUG
%! myassert(c2, c, eps)

%!test
%! % multiple points times multiple points,
%! % of different size along different dimensions:
%! na = 10 + ceil(10*rand);
%! nb = 10 + ceil(10*rand);
%! a = rand(na,3);
%! b = repmat(rand(1,3), nb,1);
%! c = dot_all(a, frontal_pt(b));
%! c2  = repmat(dot_all (a, b(1,:)), [1 1 nb]);
%! %c, c2, c2 - c  % DEBUG
%! myassert(c2, c, eps)
