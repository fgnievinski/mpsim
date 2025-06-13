function c = cross_all (a, b)
    [na,ma] = size(a);
    [nb,mb] = size(b);
    assert(ma == 3);
    assert(mb == 3);
    assert(na == nb || na == 1 || nb == 1)
    if (na == 1),  a = repmat(a, [nb,1]);  end
    if (nb == 1),  b = repmat(b, [na,1]);  end
    c = cross(a, b, 2);
end

%!test
%! n = 10;
%! a = repmat([1 0 0], n, 1);
%! b = repmat([0 1 0], n, 1);
%! c_correct = repmat([0 0 1], n, 1);
%! c_answer = cross_all (a, b);
%! myassert (c_answer, c_correct);

%!test
%! n = 10;
%! a = rand(n, 3);
%! b = rand(n, 3);
%! for i=1:n;  c_correct(i,:) = cross(a(i,:), b(i,:));  end
%! c_answer = cross_all (a, b);
%! myassert (c_answer, c_correct);

%!test
%! % one point times multiple points.
%! n = 10;
%! a = rand(n, 3);
%! b = repmat(rand(1, 3), [n,1]);
%! c  = cross_all (a, b(1,:));
%! c2 = cross_all (a, b);
%! %n, c, c2, c2 - c  % DEBUG
%! myassert(c2, c, eps)

