function pos_proj = proj_pt_line (pos_pt, pos_line, dir_line)
    n = size(pos_line, 1);
    myassert(size(dir_line, 1) == n)
    if (size(pos_pt, 1) == 1)
        pos_pt = repmat(pos_pt, n, 1);
    end
    diff_pt = pos_pt - pos_line;
    temp = dot_all(diff_pt, dir_line);
    pos_proj = pos_line + repmat(temp, 1, 3) .* dir_line;
end

%!shared
%! n = ceil(10*rand);
%! pos_pt = rand(n,3);
%! pos_line = rand(1,3);

%!test
%! % trivial case: vertical line.
%! dir_line = [0,0,1];
%! pos_proj  = horzcat(repmat(pos_line(:,1:2), n, 1), pos_pt(:,3));
%! pos_proj2 = proj_pt_line (pos_pt, pos_line, dir_line);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, eps)

%!test
%! % trivial case: horizontal, x-aligned align.
%! dir_line = [1,0,0];
%! pos_proj  = horzcat(pos_pt(:,1), repmat(pos_line(:,2:3), n, 1));
%! pos_proj2 = proj_pt_line (pos_pt, pos_line, dir_line);
%! %pos_proj, pos_proj2, pos_proj2 - pos_proj  % DEBUG
%! myassert(pos_proj2, pos_proj, eps)

