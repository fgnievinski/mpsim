function [pos_refl_horiz, delay] = snr_fwd_geometry_approx_eval (dir_sat, order, setup)
    sfc = setup.sfc;
    ref = setup.ref;
    if (order > sfc.num_specular_max)
        error('snr:snr_fwd_geometry_approx_eval:Order', ...
            'Higher-order reflections are not supported.')
    end
    %TODO: use PO calibration.
    if sfc.approximateit
        setup.sfc = setup.sfc.approx;
        [ignore, pos_refl_horiz, delay] = sfc.approx.snr_fwd_geometry_reflection (...
            dir_sat, order, setup); %#ok<ASGLU>
        pos_refl_horiz.cart(:,3) = [];
    else
        n = numel(dir_sat.elev);
        pos_refl_horiz.cart = repmat(sfc.pos_sfc0(1,1:2), [n,1]);
        delay = repmat(2*(ref.pos_ant(3) - sfc.pos_sfc0(3)), [n,1]);
    end
end

