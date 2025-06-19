function is_visible = get_occlusion (pos, dir, dist_max, step, z_fnc, is_visible_pre, N_lim)
% dist is slant not horizontal.
    if (nargin < 7) || isempty(N_lim),  N_lim = 1000;  end
    if (nargin < 6),  is_visible_pre = [];  end
    %N_lim = 1;  % DEBUG
    assert(size(pos,2)==3)
    assert(size(dir,2)==3)
    assert(size(dist_max,2)==1)  % isvector(dist_max)
    N = size(pos,1);
    if isscalar(step),  step = repmat(step, [N 1]);  end
    if isempty(is_visible_pre),  is_visible_pre = true(N,1);  end
    is_visible = is_visible_pre;
      %disp(100*sum(is_visible)/numel(is_visible))  % DEBUG
        
    %% First check only a single step for all points, at the same time:
    %% (that's a cheap way of getting rid of many points; it may also be 
    %%  the only opportunity to check elements whose dist_max < step)
    if none(is_visible),  return;  end
    is_visible(is_visible) = get_occlusion_aux (...
        pos(is_visible,:), dir(is_visible,:), dist_max(is_visible)./2, dist_max(is_visible)./2, z_fnc, Inf);
      %disp(100*sum(is_visible)/numel(is_visible))  % DEBUG

    %% Then check all steps only for surviving pts:
    if none(is_visible),  return;  end
    is_visible(is_visible) = get_occlusion_aux (...
        pos(is_visible,:), dir(is_visible,:), dist_max(is_visible), step(is_visible), z_fnc, N_lim);
      %disp(100*sum(is_visible)/numel(is_visible))  % DEBUG
end

function is_visible = get_occlusion_aux (pos, dir, dist_max, step, z_fnc, N_lim)
    N = size(pos,1);
    if isinf(N_lim)
        is_visible = get_occlusion_block (pos, dir, dist_max, step, z_fnc);
    elseif (N_lim == 1)
        is_visible = NaN(N,1);
        for i=1:N
            is_visible(i) = get_occlusion_scalar (pos(i,:), dir(i,:), dist_max(i), step(i), z_fnc);
        end
    else
        is_visible = NaN(N,1);
        ind_start = 1:N_lim:N;
        ind_end   = [(ind_start(2:end)-1), N];
        for i=1:numel(ind_start)
            %i  % DEBUG
            I = ind_start(i):ind_end(i);
            is_visible(I) = get_occlusion_block (pos(I,:), dir(I,:), dist_max(I), step(I), z_fnc);
        end
    end
end

function is_visible = get_occlusion_scalar (pos, dir, dist_max, step, z_fnc)
    dist = (0:step:dist_max)';
    if ~isscalar(dist),  dist(1) = [];  end  % don't start at the point itself.
    pos_ray = add_all(pos, multiply_all(dist, dir));

    height_ray = pos_ray(:,3);
    horz_ray = pos_ray(:,1:2);

    height_gnd = z_fnc(horz_ray);

    is_visible = all(height_ray >= height_gnd);
    is_visible(isnan(is_visible)) = true;
end

function is_visible_all = get_occlusion_block (pos_all, dir_all, dist_max_all, step_all, z_fnc)
    N = size(pos_all,1);

    if isequal(dist_max_all, step_all)
        dist_all = num2cell(dist_max_all);
        n_all = ones(N,1);
        ind_all = num2cell((1:N)');
    else
        dist_all = arrayfun(@(dist_max, step) (step:step:dist_max)', dist_max_all, step_all, 'UniformOutput',false);
        n_all = cellfun(@numel, dist_all);
        ind_all = arrayfun(@(i, n) i.*ones(n, 1), (1:N)', n_all, 'UniformOutput',false);
        %ind_all = arrayfun(@(i, n) repmat(i, [n 1]), (1:N)', n_all, 'UniformOutput',false);
        %TODO: produce dist_all2 directly, without cellfun/arrayfun & mat2cell.
        %n_all = floor(dist_max_all ./ step_all);
        %temp = cumsum(n_all);
        %dist_all2 = zeros(temp(end),1);
        %for i=1:N
        %    ind = temp(i):temp(i);
        %    dist_all2(ind) = (step_all(i):step_all(i):dist_max_all(i))';
        %end
    end

    dist_all2 = cell2mat(dist_all);
    ind_all2 = cell2mat(ind_all);
    
    pos_all2 = pos_all(ind_all2,:);
    dir_all2 = dir_all(ind_all2,:);
    pos_ray_all2 = add_all(pos_all2, multiply_all(dist_all2, dir_all2));

    height_ray_all2 = pos_ray_all2(:,3);
    horz_ray_all2 = pos_ray_all2(:,1:2);

    height_gnd_all2 = z_fnc(horz_ray_all2);
    height_gnd_all2(isnan(height_gnd_all2)) = -Inf;

    cond_all2 = (height_ray_all2 > height_gnd_all2);
    if all(n_all == 1)
        % (we're asked to check only a single step for all points)
        is_visible_all = cond_all2;
    else
        cond_all = mat2cell(cond_all2, n_all, 1);
        is_visible_all = cellfun(@all, cond_all);
    end
    is_visible_all(isnan(is_visible_all)) = true;
end

%test-TODO
% - consistency: N_lim = 1 2 inf
% - accuracy: 2d polynomial sfc, toy problem.

