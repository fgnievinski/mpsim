function m = proj_polar_stereo_get_m (phi, ell)
% this routine is shared by proj_polar_stereo and
% proj_polar_stereo_get_scale_factor.

    e = ell.e;

    m = cos(phi) ./ ( 1 - e^2 .* (sin(phi)).^2 ).^0.5;  % (14-15)

return;
