function c = times_all (a, b)
    c = bsxfun(@times, a, b);
end

%!test
%! % same dimensions:
%! num_pts = 3;
%! num_coords = 3;
%! a = rand(num_pts, num_coords);
%! b = rand(num_pts, num_coords);
%! c = a .* b;
%! c2 = times_all(a, b);
%! myassert(c2, c)

%!test
%! % same number of points:
%! num_pts = 3;  num_coords_a = 3;
%! num_pts = 3;  num_coords_b = 1;
%! a = rand(num_pts, num_coords_a);
%! b = rand(num_pts, num_coords_b);
%! c = NaN(num_pts, num_coords_a);
%! for j=1:num_coords_a
%!   c(:,j) = a(:,j) .* b; 
%! end
%! c2 = times_all(a, b);
%! c3 = times_all(b, a);
%! myassert(c2, c);
%! myassert(c3, c);

%!test
%! % same number of coordinates:
%! num_pts_a = 3;  num_coords = 3;
%! num_pts_b = 1;  num_coords = 3;
%! a = rand(num_pts_a, num_coords);
%! b = rand(num_pts_b, num_coords);
%! c = NaN(num_pts_a, num_coords);
%! for i=1:num_pts_a
%!   c(i,:) = a(i,:) .* b; 
%! end
%! c2 = times_all(a, b);
%! c3 = times_all(b, a);
%! myassert(c2, c)
%! myassert(c3, c)

