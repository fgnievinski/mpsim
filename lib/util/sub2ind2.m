% faster version of sub2ind2, with no error checking.
function ind = sub2ind2 (siz, i, j)
    ind = (j-1).*siz(1) + i;
end

%!test
%! siz = [3, 2];
%! temp = [...
%!     % i j ind
%!     1 1 1
%!     1 2 4
%!     2 1 2
%!     2 2 5
%!     3 1 3
%!     3 2 6
%! ];
%! i = temp(:,1);
%! j = temp(:,2);
%! ind = temp(:,3);
%! 
%! ind2 = sub2ind2(siz, i, j);
%! %[ind2, ind]  % DEBUG
%! myassert(ind2, ind);

%!test
%! n = ceil(10*rand);
%! siz = ceil(10*rand(1,2));
%! i = ceil(randint(1, siz(1), n, 1));
%! j = ceil(randint(1, siz(2), n, 1));
%! %siz, i, j  % DEBUG
%! ind  = sub2ind(siz, i, j);
%! ind2 = sub2ind2(siz, i, j);
%! myassert(ind2, ind)

