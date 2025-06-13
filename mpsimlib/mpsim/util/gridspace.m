function [x_grid, y_grid, x_domain, y_domain] = gridspace (x_lim, y_lim, n)
    if (nargin < 3) || isempty(n),  n = 1000;  end
    if isscalar(n),  n = round(sqrt(n));  n = [n n];  end
    [nx, ny] = deal2(n);
    x_domain = linspace(x_lim(1), x_lim(2), nx);
    y_domain = linspace(y_lim(1), y_lim(2), ny);
    [x_grid, y_grid] = meshgrid(x_domain, y_domain);
end

