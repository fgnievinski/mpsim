function delay_hess = snr_fwd_geometry_delay_hess (sfc_pos_horiz, sat_dir, pos_ant, sfc, ...
height_self, height_grad, height_hess, ...
dir_split, dist_scatt, dir_scatt)
    if (nargin < 5),  height_self = snr_fwd_geometry_height_self (sfc_pos_horiz, sfc);  end
    if (nargin < 6),  height_grad = snr_fwd_geometry_height_grad (sfc_pos_horiz, sfc);  end
    if (nargin < 7),  height_hess = snr_fwd_geometry_height_hess (sfc_pos_horiz, sfc);  end
    if (nargin < 10)
        [ignore, dir_split, dist_scatt, dir_scatt] = snr_fwd_geometry_delay_self (...
            sfc_pos_horiz, sat_dir, pos_ant, sfc, height_self); %#ok<ASGLU>
    end
    zs = dir_split(:,3);

    % horizontal gradient of the scattered direction, which is equal to the
    % horizontal gradient of the scattering bi-secting vector; (this is a 3-by-2 matrix):
    drs_dw = snr_fwd_geometry_delay_hess_aux (...
        sfc_pos_horiz, sat_dir, pos_ant, sfc, ...
        height_self, height_grad, dist_scatt, dir_scatt);
    dws_dw = drs_dw(1:2,1:2,:);
    dzs_dw = drs_dw(3,:,:);
    
    height_grad = frontal(height_grad, 'pt');
    height_hess = frontal(height_hess);
    zs = frontal(zs, 'pt');
    dws_dw = frontal(dws_dw);
    dzs_dw = frontal(dzs_dw);

    delay_hess = dws_dw + height_grad.' * dzs_dw + zs .* height_hess;

    delay_hess = defrontal(delay_hess);    
    %keyboard  % DEBUG
    
    delay_hess = -delay_hess;
end

%!test
%! test snr_fwd_geometry_delay_self

