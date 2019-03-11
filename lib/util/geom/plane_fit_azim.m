function [coeff, slope, aspect, z_fit, z_res, rmsr, rmsz, var_red] = plane_fit_azim (...
x, y, z, azim_mid, azim_tol, dist_tol, varargin)
    if (nargin < 6),  dist_tol = [];  end
    if isvector(x) && isvector(y),  [x, y] = meshgrid(x, y);  end
    siz = size(z);
    temp = cart2sph_local(xyz2neu([x(:), y(:)]));
    azim = reshape(temp(:,2), siz);
    idx = (abs(azimuth_diff(azim, azim_mid)) <= azim_tol);
    if ~isempty(dist_tol)
        dist = hypot(x, y);
        idx = idx & (dist <= dist_tol);
    end
    z_fit = NaN(siz);
    z_res = NaN(siz);
    [coeff, slope, aspect, z_fit(idx), z_res(idx), rmsr, rmsz, var_red] = plane_fit(...
        x(idx), y(idx), z(idx), varargin{:});
end
