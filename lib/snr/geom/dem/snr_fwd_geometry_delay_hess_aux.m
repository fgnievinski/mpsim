function dir_grad = snr_fwd_geometry_delay_hess_aux (sfc_pos_horiz, sat_dir, pos_ant, sfc, ...
height_self, height_grad, dist_scatt, dir_scatt)
    if (nargin < 5),  height_self = snr_fwd_geometry_height_self (sfc_pos_horiz, sfc);  end
    if (nargin < 6),  height_grad = snr_fwd_geometry_height_grad (sfc_pos_horiz, sfc);  end
    if (nargin < 8)
        [dist_scatt, dir_scatt] = snr_fwd_geometry_delay_self_scatt (...
            sfc_pos_horiz, sat_dir, pos_ant, sfc, height_self);
    end
    dist = dist_scatt;
    dir = dir_scatt;
    [x_dir, y_dir, z_dir] = deal2(neu2xyz(dir));
    [dz_dx, dz_dy] = deal2(neu2xyz(height_grad));
    dist_inv = 1 ./ dist;
    dxdir_dx = dist_inv .* (x_dir .* x_dir + x_dir .* z_dir .* dz_dx - 1);
    dydir_dy = dist_inv .* (y_dir .* y_dir + y_dir .* z_dir .* dz_dy - 1);
    dzdir_dx = dist_inv .* (x_dir .* z_dir + z_dir .* z_dir .* dz_dx - dz_dx);
    dzdir_dy = dist_inv .* (y_dir .* z_dir + z_dir .* z_dir .* dz_dy - dz_dy);
    dydir_dx = dist_inv .* (x_dir .* y_dir + y_dir .* z_dir .* dz_dx);
    dxdir_dy = dist_inv .* (y_dir .* x_dir + x_dir .* z_dir .* dz_dy);
    dxdir_dx = frontal_pt(dxdir_dx);
    dydir_dy = frontal_pt(dydir_dy);
    dxdir_dy = frontal_pt(dxdir_dy);
    dydir_dx = frontal_pt(dydir_dx);
    dzdir_dx = frontal_pt(dzdir_dx);
    dzdir_dy = frontal_pt(dzdir_dy);
    %dir_grad = [...
    %    dydir_dy, dxdir_dy;
    %    dydir_dx, dxdir_dx;
    %    dzdir_dy, dzdir_dx;
    %]; % WRONG!
    dir_grad = [...
        dydir_dy, dydir_dx;
        dxdir_dy, dxdir_dx;
        dzdir_dy, dzdir_dx;
    ];
    % this is the horizontal gradient of the scattered direction.
    % which equals the horizontal gradient of the scattering bi-secting vector.
end

%!shared
%! function answer = get_dir_deriv2 (pos_sfc_horiz, sat_dir, pos_ant, sfc)
%!     function dir = get_dir (pos_sfc_horiz)
%!         [ignore, dir] = snr_fwd_geometry_delay_self_scatt (...
%!             pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     end
%!     answer = diff_func_obs(...
%!         @(pos_sfc_horiz_) get_dir(pos_sfc_horiz_), ...
%!         pos_sfc_horiz);
%!     %answer(1) = diff_func(...
%!     %    @(sfc_y_) getel(get_dir([sfc_y_, pos_sfc_horiz(:,2)]), 1), ...
%!     %    pos_sfc_horiz(:,1))  % DEBUG
%! end
%! function answer = get_dir_deriv3 (pos_sfc_horiz, sat_dir, pos_ant, sfc)
%!     function dir = get_dir (pos_sfc_horiz)
%!         [ignore, dir] = snr_fwd_geometry_delay_self (...
%!             pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     end
%!     answer = diff_func_obs(...
%!         @(pos_sfc_horiz_) get_dir(pos_sfc_horiz_), ...
%!         pos_sfc_horiz);
%! end
%! %sfc_coeff = randint(-1,+1, [3,3]);
%! sfc_coeff = [];  % plane
%! sfc_coeff = randint(-1,+1, [2,2]);
%! pos_ant = [0 0 2];
%! opt = struct('pos_ant',pos_ant, 'pos_sfc0',[0 0 0]);
%! sett_sfc = struct('type','poly', 'coeff',sfc_coeff);
%! sfc = snr_setup_sfc_geometry_dem (opt, sett_sfc);

%!test
%! % random input:
%! sat_dir = normalize_vec(rand(1,3));
%! %for i=1:2
%! for i=1
%!     % single point, then multiple points:
%!     switch i,  case 1, num_pts = 1;  case 2,  num_pts = 4;  end
%!     pos_sfc_horiz = randint(-10,+10, [num_pts,2]);
%!     answer1 = snr_fwd_geometry_delay_hess_aux (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     answer2 = get_dir_deriv2 (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     answer3 = get_dir_deriv3 (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!       %answer1 - answer2  % DEBUG
%!       %answer1 - answer3  % DEBUG
%!     myassert(answer1, answer2, -sqrt(eps()))
%!     myassert(answer1, answer3, -sqrt(eps()))
%! end

%!test
%! % we were getting a NaN when sat_dir and sfc_pos have the same azimuth.
%! sat_dir = sph2cart_local([25, 0, 1]);
%! pos_sfc_horiz = [1, 0];
%! for i=1
%!     answer1 = snr_fwd_geometry_delay_hess_aux (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     answer2 = get_dir_deriv2 (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!     answer3 = get_dir_deriv3 (pos_sfc_horiz, sat_dir, pos_ant, sfc);
%!       %answer1 - answer2  % DEBUG
%!       %answer1 - answer3  % DEBUG
%!     myassert(answer1, answer2, -sqrt(eps()))
%!     myassert(answer1, answer3, -sqrt(eps()))
%! end

