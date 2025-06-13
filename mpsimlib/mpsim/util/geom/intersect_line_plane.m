function [pos_inter, is_line_facing_plane, is_degenerate] = ...
intersect_line_plane (...
pos_line, dir_line, pos_plane, vec_plane)
    N = size(pos_plane,1);  assert(size(vec_plane,1) == N);
    [n,m] = size(pos_line);  assert(size(dir_line,1) == n);
    pos_inter = NaN(n,m,N);  % N frontal pages.
    is_line_facing_plane = NaN(n,1,N);
    is_degenerate = NaN(n,1,N);
    for i=1:N
        [pos_inter(:,:,i), is_line_facing_plane(:,:,i), is_degenerate(:,:,i)] = ...
            intersect_line_plane1 (pos_line, dir_line, pos_plane(i,:), vec_plane(i,:));
    end
end

% (one plane, multiple lines.)
function [pos_inter, is_line_facing_plane, is_degenerate] = ...
intersect_line_plane1 (...
pos_line, dir_line, pos_plane, vec_plane)
    n = size(pos_line, 1);  myassert(size(dir_line, 1) == n)
    diff_line = minus_all(pos_line, pos_plane);
    temp1 = dot_all(dir_line, vec_plane);
    if isa(temp1, 'sym')
        is_line_facing_plane = NaN(n,1);
        is_degenerate = NaN(n,1);
    else
        is_line_facing_plane = (temp1 > 0);
        is_degenerate = (abs(temp1) < eps);
    end
    temp2 = dot_all(diff_line, vec_plane);
    temp3 = - temp2 ./ temp1;  % (norm of vec_plane cancels out here.)
    pos_inter = plus_all(pos_line, times_all(temp3, dir_line));
end

%!shared
%! n = 1 + ceil(10*rand);
%! %n = 250;
%! pos_plane = rand(1,3);
%! pos_line  = rand(n,3);

%!test
%! % trivial case: horizontal plane, vertical line.
%! dir_plane = [0,0,1];
%! dir_line  = repmat([0,0,1], n, 1);
%! pos_inter = horzcat(pos_line(:,1:2), repmat(pos_plane(:,3), n, 1));
%! pos_inter2 = intersect_line_plane (pos_line, dir_line, pos_plane, dir_plane);
%! %pos_inter, pos_inter2, pos_inter2 - pos_inter  % DEBUG
%! myassert(pos_inter2, pos_inter, eps)

%!test
%! % trivial case: vertical plane, horizontal line.
%! dir_plane = [0,1,0];
%! dir_line  = repmat([0,1,0], n, 1);
%! pos_inter = horzcat(pos_line(:,1), repmat(pos_plane(:,2), n, 1), pos_line(:,3));
%! pos_inter2 = intersect_line_plane (pos_line, dir_line, pos_plane, dir_plane);
%! %pos_inter, pos_inter2, pos_inter2 - pos_inter  % DEBUG
%! myassert(pos_inter2, pos_inter, eps)

%!test
%! % degenerate case: horizontal plane, horizontal line.
%! dir_plane = [0,0,1];
%! dir_line  = repmat([0,1,0], n, 1);
%! [ignore, is_line_facing_plane, is_degenerate] = ...
%!     intersect_line_plane (pos_line, dir_line, pos_plane, dir_plane);
%! %is_degenerate  % DEBUG
%! myassert(all(is_degenerate))

%!test
%! % nearly degenerate case: horizontal plane, horizontal line.
%! dir_plane = [0,0,1];
%! dir_line = repmat(sph2cart_local([eps, 0, 1]), n, 1);
%! [ignore, is_line_facing_plane, is_degenerate] = ...
%!     intersect_line_plane (pos_line, dir_line, pos_plane, dir_plane);
%! %is_degenerate  % DEBUG
%! myassert(all(is_degenerate))

%!test
%! % plane normal vector needs not be (unit) normalized.
%! vec_plane = randint(-1,+1, 1,3);
%! dir_plane = normalize_vec(vec_plane);
%! dir_line = normalize_vec(randint(-1,+1, n,3));
%! pos_inter  = intersect_line_plane (pos_line, dir_line, pos_plane, dir_plane);
%! pos_inter2 = intersect_line_plane (pos_line, dir_line, pos_plane, vec_plane);
%! %pos_inter, pos_inter2, pos_inter2 - pos_inter  % DEBUG
%! myassert(pos_inter2, pos_inter, -sqrt(eps))

%!test
%! % line is not facing the plane.
%! dir_plane = [0,0,1];  % (up)
%! pos_plane = rand(1,3);
%! pos_line  = rand(n,3);
%! pos_line(3) = pos_plane(3) - pos_line(3);  % put pos_line below the plane.
%! 
%! dir_line = sph2cart_local([...  % line pointing away from plane.
%!     randint(-90,-eps, [n,1]), randint(0,360, [n,1]), ones(n,1)]);
%! [pos_inter, is_line_facing_plane] = intersect_line_plane (...
%!     pos_line, dir_line, pos_plane, dir_plane);
%! myassert(~any(is_line_facing_plane))
%! 
%! dir_line = sph2cart_local([...  % line pointing towards plane.
%!     randint(eps,+90, [n,1]), randint(0,360, [n,1]), ones(n,1)]);
%! [pos_inter, is_line_facing_plane] = intersect_line_plane (...
%!     pos_line, dir_line, pos_plane, dir_plane);
%! myassert(all(is_line_facing_plane))

%!test
%! % multiple planes
%! pos_line  = rand(n,3);
%! dir_line  = normalize_pt(rand(n,3));
%! N = 2;
%! pos_plane = repmat(rand(1,3), [N 1]);
%! vec_plane = repmat(rand(1,3), [N 1]);
%! pos_inter = intersect_line_plane (pos_line, dir_line, pos_plane(1,:), vec_plane(1,:));
%! pos_inter = repmat(pos_inter, [1 1 N]);
%! pos_inter2 = intersect_line_plane (pos_line, dir_line, pos_plane, vec_plane);
%! %pos_inter, pos_inter2, pos_inter2 - pos_inter  % DEBUG
%! myassert(pos_inter2, pos_inter, eps)
