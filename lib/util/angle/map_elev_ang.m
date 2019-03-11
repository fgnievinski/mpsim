function [e, tane] = map_elev_ang (x, y, z, x0, y0, z0)
    if (nargin < 6) || isempty(z0),  z0 = interp2(x, y, z, x0, y0);  end
    if (numel(x) == 2),  x = linspace(x(1), x(2), size(z,2));  end
    if (numel(y) == 2),  y = linspace(y(1), y(2), size(z,1));  end
    if isvector(x) || isvector(y),  [x, y] = meshgrid(x, y);  end
    dx = x - x0;
    dy = y - y0;
    dz = z - z0;
    ds = sqrt(dx.^2 + dy.^2);
    tane = dz./ds;
    e = atand(tane);
    %% DEBUG:
    %figure,  imagesc(ds),  colorbar
    %figure,  imagesc(dz),  colorbar
    %figure,  imagesc(tane),  colorbar
end

