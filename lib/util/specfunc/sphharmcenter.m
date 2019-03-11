function [center_cart, radius, jacob] = sphharmcenter (pos_sph, obs, degree, tol, jacob)
    if (nargin < 3) || isempty(degree),  degree = 1;  end
    if (nargin < 4) || isempty(tol),  tol = NaN;  end
    if (nargin < 5),  jacob = [];  end
    
    % as per eq.(2) in doi:10.1016/j.jog.2012.01.007
    get_center_from_coeff_real = @(coeff_real) coeff_real([3,4,2])'.*sqrt(3);
    
    was_jacob_empty = isempty(jacob);
    [coeff, jacob] = sphharmreal_fit (pos_sph, obs, degree, jacob);
    center_cart = get_center_from_coeff_real (coeff);
    radius = coeff(1);
    %center_cart  % DEBUG
    if isnan(tol) || all(abs(center_cart) < tol),  return;  end
    
    %pos_sph(:,3) = radius;  % WRONG!
    pos_sph(:,3) = obs;
    %pos_cart = convert_to_cartesian (pos_sph);  % WRONG!
    pos_cart = convert_to_cartesian_from_spherical (pos_sph);
    pos_cart2 = minus_all(pos_cart, center_cart);
    pos_sph2 = convert_to_spherical (pos_cart2);
    radius2 = pos_sph2(:,3);
    obs2 = radius2;
    if was_jacob_empty,  jacob = [];  end  % force recalculation with pos_sph2
    [center_cart2, radius, jacob] = sphharmcenter (pos_sph2, obs2, degree, tol, jacob);
    center_cart = center_cart - center_cart2;
end
