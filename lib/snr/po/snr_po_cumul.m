function answer = snr_po_cumul (answer)
    %TODO: use spm
    %% Fresnel zones:
    [answer.map.fresnel_zone, answer.map.fresnel_zone_number] = delay2fresnel (...
        answer.map.delay, answer.opt.wavelength);

    %% Delay-contiguous pixels:
    % minimum delay along grid borders:
    answer.info.fz_border = min(answer.map.fresnel_zone(get_border_ind(answer.map.fresnel_zone)));    
    answer.map.contiguous = (answer.map.fresnel_zone < answer.info.fz_border);
    %answer.map.contiguous = (answer.map.fresnel_zone <= answer.info.fz_border);
        
    %% Delay-based phasor accumulating function:
    answer.map.ind_delay = reshape(argsort(answer.map.delay(:)), size(answer.map.delay));
    answer.map.ind_delay_inv = reshape(invsort(answer.map.ind_delay(:)), size(answer.map.ind_delay));
    answer.map.ind0 = answer.map.ind_delay(:);  % (legacy interface)
    answer.map.ind1 = answer.map.ind_delay_inv(:);  % (legacy interface)

    %% Cumulative phasor:
    answer.map.cphasor = snr_po_accum (answer.map.phasor, ...
        answer.map.ind_delay, answer.map.ind_delay_inv, answer.map.contiguous);
end

