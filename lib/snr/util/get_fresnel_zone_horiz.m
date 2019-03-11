function answer = get_fresnel_zone_horiz (height, elev, azim, wavelength, zone, ...
dang, step, form)
    if (nargin < 1),  height = [];  end
    if (nargin < 2),  elev = [];  end
    if (nargin < 3),  azim = [];  end
    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5),  zone = [];  end
    if (nargin < 6),  dang = [];  end
    if (nargin < 7),  step = [];  end
    if (nargin < 8),  form = [];  end
    [siz, num, height, elev, azim, wavelength, zone] = get_fresnel_zone_input (...
        height, elev, azim, wavelength, zone);

    [R, a, b] = get_fresnel_zone_dim (height, elev, wavelength, zone, form);
    [x, y] = get_ellipse_points (a, b, R, dang, num);
    [x, y] = get_ellipse_points_thinned (x, y, step, num);
    [x, y] = get_ellipse_points_rotated (x, y, azim, num);

    pos = cellfun2(@(xi, yi) xyz2neu(xi,yi), x, y);
    
    if (num == 1)
        x  = x{1};
        y  = y{1};
        pos = pos{1};
    end

    answer = struct();
    answer.a = reshape(a, siz);
    answer.b = reshape(b, siz);
    answer.R = reshape(R, siz);
    answer.x = x;
    answer.y = y;
    answer.pos = pos;
    answer.R_max = R + a;
    answer.R_min = R - a;
    
    return
    [x0, y0] = get_ellipse_points_rotated (...
        num2cell(a), num2cell(zeros(num,1)), azim, num);
    pos0 = cellfun2(@(xi, yi) xyz2neu(xi,yi), x0, y0);
    x0 = cell2mat(x0);
    y0 = cell2mat(y0);
    pos0 = cell2mat(pos0);
    answer.x0 = x0;
    answer.y0 = y0;
    answer.pos0 = pos0;
end

%%
function [x, y] = get_ellipse_points (a, b, R, dang, num)
    if isempty(dang),  dang = 1;  end
    ang = (0:dang:360)';
    ang(end) = [];  % 360=0
    myarrayfun2 = @(f) arrayfun2(f, (1:num)');
    x = myarrayfun2(@(i) a(i) * cosd(ang) + R(i));
    y = myarrayfun2(@(i) b(i) * sind(ang));
end

%%
function [x2, y2] = get_ellipse_points_thinned (x, y, step, num)
    if isempty(step),  step = 0.15;  end
    x2 = cell(num,1);
    y2 = cell(num,1);
    for i=1:num  % (for each ellipse -- not for each point.)
        [x2{i}, y2{i}] = get_ellipse_points_thinned_ith (x{i}, y{i}, step);
    end
end

%%
function [x2, y2] = get_ellipse_points_thinned_ith (x, y, step)
    if any(~isfinite(x) | ~isfinite(y))
        x2 = [];
        y2 = [];
        return;
    end
    if isscalar(x) || isscalar(y)
        x2 = x;
        y2 = y;
        return;
    end
    dx = [0; diff(x)];
    dy = [0; diff(y)];
    dlen = sqrt(dx.^2 + dy.^2);
    len = cumsum(dlen);
    if (len(end) == 0)  % infinitesimal FZ (sp. pt)
        x2 = [];
        y2 = [];
        return;
    end
    
    len2 = (0:step:max(len))';
    len2(end+1) = max(len);
    len2 = interp1(len, len, len2, 'nearest');
    len2 = unique(len2);
    ind = ismember(len, len2);
    x2 = x(ind);
    y2 = y(ind);
    %figure, hold on, plot(x, y, '.-k'), plot(x2, y2, 'ok'), axis equal
end

%%
function [x2, y2] = get_ellipse_points_rotated (x, y, azim, num)
    cos_azim = cosd(azim);
    sin_azim = sind(azim);
    arrayfun2 = @(f) arrayfun(f, (1:num)', 'UniformOutput',false);
    x2 = arrayfun2(@(i) sin_azim(i) * x{i} - cos_azim(i) * y{i});
    y2 = arrayfun2(@(i) sin_azim(i) * y{i} + cos_azim(i) * x{i});
end
