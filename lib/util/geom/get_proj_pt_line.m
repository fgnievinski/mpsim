% returns the projection of a point on a straight-line.
function [dist, pt2, dist2] = get_proj_pt_line (pt, line_pt, line_dir)
    if abs(norm_all(line_dir) - 1) > sqrt(eps)
        error('MATLAB:get_proj_pt_line:badInput', ...
            'Third argument should be a unit vector.');
    end

    myassert(size(line_pt), size(line_dir))
    n = size(pt,1);
    if (size(line_pt,1) ~= size(pt,1))
        line_pt = repmat(line_pt, n, 1);
        line_dir = repmat(line_dir, n, 1);
    end

    dist = dot_all (pt - line_pt, line_dir);

    if (nargout < 2),  return;  end
    pt2 = line_pt + line_dir .* repmat(dist, 1, 3);

    if (nargout < 3),  return;  end
    dist2 = norm_all (pt2 - pt);
end

%!test
%! % line coinciding with any of the axes:
%! line_dir = [1, 0, 0];
%! line_pt  = [0, 0, 0];
%! pt = 100*rand(1,3);
%! pt2 = [pt(1) 0 0];
%! dist = pt(1);
%! dist2 = sqrt(pt(2)^2 + pt(3)^2);
%! 
%! [dist_answer, pt2_answer, dist2_answer] = get_proj_pt_line (...
%!     pt, line_pt, line_dir);
%! 
%! myassert(pt2_answer, pt2)
%! myassert(dist_answer, dist)
%! myassert(dist2_answer, dist2)

%!test
%! % line paralel to any of the axes:
%! line_dir = [1, 0, 0];
%! line_pt = 100*rand(1,3);
%! pt = 100*rand(1,3);
%! pt2 = [pt(1) line_pt(2:3)];
%! dist = pt(1) - line_pt(1);
%! dist2 = sqrt((pt(2) - line_pt(2))^2 + (pt(3) - line_pt(3))^2);
%! 
%! %figure
%! %hold on
%! %plot(line_pt(1), line_pt(2), 'ob')
%! %quiver(line_pt(1), line_pt(2), line_dir(1), line_dir(2))
%! %plot(pt(1), pt(2), 'or')
%! 
%! [dist_answer, pt2_answer, dist2_answer] = get_proj_pt_line (...
%!     pt, line_pt, line_dir);
%! 
%! %pt2_answer - pt2  % DEBUG
%! myassert(pt2_answer, pt2, -sqrt(eps))
%! myassert(dist_answer, dist, -sqrt(eps))
%! myassert(dist2_answer, dist2, -sqrt(eps))

%!test
%! % point coincident with line:
%! line_pt = rand(1,3);
%! temp = rand(1,3);  line_dir = temp ./ norm_all(temp);
%! dist = rand;
%! pt = line_pt + line_dir * dist;
%! pt2 = pt;
%! dist2 = 0;
%! 
%! [dist_answer, pt2_answer, dist2_answer] = get_proj_pt_line (...
%!     pt, line_pt, line_dir);
%! 
%! %pt2_answer - pt2  % DEBUG
%! myassert(pt2_answer, pt2, -sqrt(eps))
%! myassert(dist_answer, dist, -sqrt(eps))
%! myassert(dist2_answer, dist2, -sqrt(eps))

%!test
%! % multiple points, single direction
%! line_pt = rand(1,3);
%! temp = rand(1,3);  line_dir = temp ./ norm_all(temp);
%! n = ceil(10*rand);
%! dist = rand(n,1);
%! pt = repmat(line_pt, n, 1) + repmat(line_dir, n, 1) .* repmat(dist, 1, 3);
%! pt2 = pt;
%! dist2 = repmat(0, n, 1);
%! 
%! [dist_answer, pt2_answer, dist2_answer] = get_proj_pt_line (...
%!     pt, line_pt, line_dir);
%! 
%! %pt2_answer - pt2  % DEBUG
%! myassert(pt2_answer, pt2, -sqrt(eps))
%! myassert(dist_answer, dist, -sqrt(eps))
%! myassert(dist2_answer, dist2, -sqrt(eps))

%!test
%! % get_proj_pt_line()
%! s = lasterror('reset');

%!error
%! get_proj_pt_line ([], [], [5,0,0]);

%!test
%! % get_proj_pt_line()
%! s = lasterror();
%! myassert(s.identifier, 'MATLAB:get_proj_pt_line:badInput')

