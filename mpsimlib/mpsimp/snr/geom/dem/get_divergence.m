function [D, extra] = get_divergence (dist_scatt, dir_sat, dir_nrml, ...
dz_dx, dz_dy, dz_dxx, dz_dyy, dz_dxy)
    dir_sat = neu2xyz(dir_sat);
    dir_nrml = neu2xyz(dir_nrml);

    % (Formulation as per Kravtsov (2005) and Patrikalakis and Maekawa (2009).)
    
    %% Coefficients of the first and second fundamental forms of differential geometry:
    % (for the special case of a height surface, i.e., a bi-variate uni-valued function)
    E = 1 + dz_dx.^2;
    F = dz_dx .* dz_dy;
    G = 1 + dz_dy.^2;
    n = sqrt(dz_dx.^2 + dz_dy.^2 + 1);
    L = dz_dxx ./ n;
    M = dz_dxy ./ n;
    N = dz_dyy ./ n;
    %Nvec = divide_all([-dz_dx, -dz_dy, ones(size(dz_dx)], n);

    %% Curvature of the ground surface:
    K = (L.*N - M.^2) ./ (E.*G - F.^2);  % Gaussian curvature
    H = (E.*N + G.*L - 2*F.*M) ./ (2*(E.*G - F.^2));  % mean curvature
    
    %% Tangent vector corresponding to anti-incident direction:
    cos_ang_incid = dot_all(dir_sat, dir_nrml);
    vec_tan = dir_sat - times_all(cos_ang_incid, dir_nrml);
    magn_tan = norm_all(vec_tan);
    dir_tan = divide_all(vec_tan, magn_tan);
    % some additional results:
    %dir_tan2 = dir_tan;  % WRONG!
    dir_tan2 = neu2xyz(dir_tan);      % <<<<<<<<<<<<< CHECK THIS.
    du = dir_tan2(:,1);
    dv = dir_tan2(:,2);
    lambda = du ./ dv;
    sin_ang_incid = magn_tan;
      %max(abs(norm_all(cross_all(dir_sat, dir_nrml)) - magn_tan))  % DEBUG
    tan_ang_incid = sin_ang_incid ./ cos_ang_incid;
    
    %% Curvature of the normal section:
    % (i.e., curvature of the ground surface along the normal section 
    % defined by the ray incident direction and the surface normal direction, 
    % i.e., the plane of incidence)
    II2 = L + 2*M.*lambda + N.*lambda.^2;
     I2 = E + 2*F.*lambda + G.*lambda.^2;
    kappan = II2 ./ I2;

    %% Check:
    kappan_alt = 2*H.*kappan + K;
    temp1 = kappan - kappan_alt;
    temp2 = max(abs(temp1(:)));
%     disp([kappan, kappan_alt, temp1, 100*temp1./kappan])  % DEBUG
%     %kn = kn_alt;  % DEBUG
%     if (temp2 > nthroot(eps(),2))
%         warning('snr:get_divergence:failed', ...
%             'Inconsistent ray divergence (%g).', temp2);
%     end

    %% Curvature of reflected wavefront:
    Kr = 4 * K;  % Gaussian curvature
    Hr = cos_ang_incid .* (2 * H + kappan .* tan_ang_incid.^2);  % mean curvature

    %% Finally, divergence factor for the amplitude of a pencil or tube of rays:
    dr = dist_scatt;
    D = 1./sqrt(Kr .* dr.^2 - 2 * Hr .* dr + 1);
    
    %% Extra results:
    extra = struct('E',E, 'F',F, 'G',G, 'L',L, 'M',M, 'N',N, 'n',n, ...
        'K',K, 'H',H, 'I',I2, 'II',II2, 'kappan',kappan, 'Kr',Kr, 'Hr',Hr);
end

% Example 3.5.1
