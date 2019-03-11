function [delay_grad_horiz, height_grad_horiz] = snr_fwd_geometry_delay_grad (...
sfc_pos_horiz, sat_dir, pos_ant, sfc, dir_split)
    if (nargin < 5)
        [ignore, dir_split] = snr_fwd_geometry_delay_self (...
            sfc_pos_horiz, sat_dir, pos_ant, sfc); %#ok<ASGLU>
    end
    height_grad_horiz = snr_fwd_geometry_height_grad (sfc_pos_horiz, sfc);
    delay_grad_horiz = dir_split(:,1:2) ...
                     + times_all(dir_split(:,3), height_grad_horiz);
    delay_grad_horiz = -delay_grad_horiz;
end

%!test
%! test snr_fwd_geometry_delay_self

