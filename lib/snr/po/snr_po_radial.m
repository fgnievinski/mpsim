function answer = snr_po_radial (answer)
    %answer.map.radius = hypot(answer.map.x, answer.map.y);
    answer.map.radius = sqrt(answer.map.x.^2 + answer.map.y.^2);

    answer.map.ind_radius = reshape(argsort(answer.map.radius(:)), size(answer.map.radius));
    answer.map.ind_radius_inv = reshape(invsort(answer.map.ind_radius(:)), size(answer.map.radius));

    answer.map.rphasor = snr_po_accum (answer.map.phasor, ...
        answer.map.ind_radius, answer.map.ind_radius_inv);    
end

