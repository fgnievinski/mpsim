function [z, dist, x, y] = dem_cross_section (dem, azim, dist_lim, num_pts, method, deal_nans)
    if (nargin < 2) || isempty(azim),  azim = 0;  end
    if (nargin < 3) || isempty(dist_lim),  dist_lim = 50;  end
    if (nargin < 4) || isempty(num_pts),  num_pts = 25;  end
    if (nargin < 5) || isempty(method),  method = 'linear';  end
    if (nargin < 6) || isempty(deal_nans),  deal_nans = false;  end
    interp2which = @interp2;  if deal_nans,  interp2which = @interp2nanz;  end
    if isscalar(dist_lim),  dist_lim = [0 dist_lim];  end
    dist = linspace(dist_lim(1), dist_lim(2), num_pts)';
    x = sind(azim).*dist;
    y = cosd(azim).*dist;
    z = interp2which(dem.x, dem.y, dem.z, x, y, method, NaN);
end

