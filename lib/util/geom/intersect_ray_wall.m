function [dist_inter_min, pos_inter_min] = intersect_ray_wall (pos_ray, dir_ray, x_lim, y_lim)
    pos_ray = neu2xyz(pos_ray);
    dir_ray = neu2xyz(dir_ray);
    pos_plane = [...
        mean(x_lim)  max(y_lim) 0  % North
         max(x_lim) mean(y_lim) 0  % East
        mean(x_lim)  min(y_lim) 0  % South
         min(x_lim) mean(y_lim) 0  % West
    ];
    dir_plane = [...
         0 +1 0  % North-facing
        +1  0 0  % East-facing
         0 -1 0  % South-facing
        -1  0 0  % West-facing
    ];
    [pos_inter, is_ray_facing_plane] = intersect_line_plane (...
        pos_ray, dir_ray, pos_plane, dir_plane);
    dist_inter = norm_all(minus_all(pos_ray, pos_inter));
    dist_inter(~is_ray_facing_plane) = Inf;  % disable negative distances.
    [dist_inter_min, ind_min] = min(dist_inter, [], 3);
    %keyboard
    if (nargout < 2),  return;  end
    [n,m,p] = size(pos_inter);
    I = repmat((1:n)', [1 m]);
    J = repmat(1:m, [n 1]);
    K = repmat(ind_min(:), [1 m]);
    ind = sub2ind([n m p], I, J, K);
    pos_inter_min = pos_inter(ind);
    pos_inter_min = xyz2neu(pos_inter_min);
end

%!test 
%! % trivial: axis-aligned
%! N = 10;
%! pos_ray = rand(N,3);
%! lo_lim = min(pos_ray);
%! hi_lim = max(pos_ray);
%! [x_lim(1), y_lim(1)] = neu2xyz(lo_lim(1:2));
%! [x_lim(2), y_lim(2)] = neu2xyz(hi_lim(1:2));
%! dir_ray = repmat(xyz2neu([0 1 0]), [N 1]);
%! 
%! temp = neu2xyz(pos_ray);
%! dist_inter_min = y_lim(2) - temp(:,2);
%! pos_inter_min = pos_ray;
%! pos_inter_min = neu2xyz(pos_inter_min);
%! pos_inter_min(:,2) = pos_inter_min(:,2) + dist_inter_min;
%! pos_inter_min = xyz2neu(pos_inter_min);
%! 
%! [dist_inter_min2, pos_inter_min2] = intersect_ray_wall (pos_ray, dir_ray, x_lim, y_lim);
%! %whos dist_inter_min* pos_inter_min*  % DEBUG
%! %dist_inter_min, dist_inter_min2, dist_inter_min2-dist_inter_min  % DEBUG
%! %pos_inter_min, pos_inter_min2, pos_inter_min2-pos_inter_min  % DEBUG
%! myassert(dist_inter_min, dist_inter_min2, eps)
%! myassert(pos_inter_min, pos_inter_min2, eps)

%!test 
%! % general case, visual check:
%! N = 10;
%! pos_ray = rand(N,3);
%! lo_lim = min(pos_ray);
%! hi_lim = max(pos_ray);
%! [x_lim(1), y_lim(1)] = neu2xyz(lo_lim(1:2));
%! [x_lim(2), y_lim(2)] = neu2xyz(hi_lim(1:2));
%! dir_ray = normalize_all(rand(N,3));
%! 
%! [dist_inter_min, pos_inter_min] = intersect_ray_wall (pos_ray, dir_ray, x_lim, y_lim);
%! 
%! figure
%!   hold on
%!   vline(x_lim(1))
%!   vline(x_lim(2))
%!   hline(y_lim(1))
%!   hline(y_lim(2))
%!   vline(x_lim(1))
%!   vline(x_lim(2))
%!   plot(...
%!     transpose([pos_ray(:,2) pos_inter_min(:,2) NaN(N,1)]), ...
%!     transpose([pos_ray(:,1) pos_inter_min(:,1) NaN(N,1)]), ...
%!     '-m', 'LineWidth',2)
%!   quiver(pos_ray(:,2), pos_ray(:,1), dir_ray(:,2), dir_ray(:,1), 'or')
%!   plot(pos_inter_min(:,2), pos_inter_min(:,1), '.k')
%!   axis equal
