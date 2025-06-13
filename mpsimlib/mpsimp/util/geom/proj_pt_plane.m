function pos_proj = proj_pt_plane (pos_pt, pos_plane, vec_plane, ...
is_vec_normalized)
    %whos  % DEBUG
    if (nargin < 4) || isempty(is_vec_normalized)
        is_vec_normalized = false;
    end
    n = size(pos_pt, 1);
    %whos pos_plane vec_plane  % DEBUG
    myassert(size(pos_plane), size(vec_plane))
    if (size(pos_plane, 1) == 1)
        pos_plane = repmat(pos_plane, n, 1);
        vec_plane = repmat(vec_plane, n, 1);
    end
    diff_pt = pos_pt - pos_plane;
    temp = dot_all(diff_pt, vec_plane);
    if ~is_vec_normalized,  temp = temp ./ dot_all(vec_plane);  end
    pos_proj = pos_pt - repmat(temp, 1, 3) .* vec_plane;
    %pos_proj = pos_plane + diff_pt - repmat(temp, 1, 3) .* vec_plane;
end

%!shared
%! n = ceil(10*rand);
%! pos_pt = rand(n,3);
%! pos_plane = rand(1,3);

%!test
%! % trivial case: horizontal plane.
%! dir_plane = [0,0,1];
%! pos_proj  = horzcat(pos_pt(:,1:2), repmat(pos_plane(:,3), n, 1));
%! pos_proj2 = proj_pt_plane (pos_pt, pos_plane, dir_plane);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, eps)

%!test
%! % trivial case: vertical plane.
%! dir_plane = [0,1,0];
%! pos_proj  = horzcat(pos_pt(:,1), repmat(pos_plane(:,2), n, 1), pos_pt(:,3));
%! pos_proj2 = proj_pt_plane (pos_pt, pos_plane, dir_plane);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, eps)

%!test
%! % any given point should have the same, unique projection on a given
%! % plane, regardless of the point defining that plane.
%! pos_pt = rand(1,3);
%! dir_plane = normalize_pt(randint(-1,+1, [1,3]));
%! pos_plane0 = rand(1,3);
%! pos_proj0 = proj_pt_plane (pos_pt, pos_plane0, dir_plane);
%! n = 1 + ceil(10*rand);
%! %pos_plane = rand(n,3);  % WRONG!
%! pos_plane = NaN(n,3);
%! pos_plane(:,1:2) = rand(n,2);
%! pos_plane(:,3) = plane_eval (pos_plane(:,1:2), pos_plane0, dir_plane);
%! pos_proj = NaN(n,3);
%! for i=1:n
%!   pos_proj(i,:) = proj_pt_plane (pos_pt, pos_plane(i,:), dir_plane);
%! end
%! pos_proj2 = repmat(pos_proj0, [n,1]);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, -100*eps)

%!test
%! % unnormalized plane normal vector.
%! vec_plane = randint(-1,+1, 1,3);
%! dir_plane = normalize_vec(vec_plane);
%! dir_line = normalize_vec(randint(-1,+1, n,3));
%! pos_proj  = proj_pt_plane (pos_pt, pos_plane, vec_plane);
%! pos_proj2 = proj_pt_plane (pos_pt, pos_plane, dir_plane, true);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, -100*eps)

