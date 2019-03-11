function t = proj_polar_stereo_get_t (phi, ell)
% this routine is shared by proj_polar_stereo and
% proj_polar_stereo_get_scale_factor.

    e = ell.e;

    % two formulas are given for the same quantity:
    t1 = ( ( (1 - sin(phi)) ./ (1 + sin(phi)) ) ...
         .*( (1+e.*sin(phi)) ./ (1-e.*sin(phi)) ).^e ).^0.5;  % (15-9)
         
    t2 = tan(pi/4 - phi./2) ./ ...
        ( (1-e.*sin(phi)) ./ (1+e.*sin(phi)) ).^(e/2);  % (15-9a)

    % they shall give the same result:
    %myassert (all( abs(t1 - t2) < 1e-10 | isnan(t1 - t2) ));

    t = t1;

return;

