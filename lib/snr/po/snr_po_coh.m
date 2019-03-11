function answer = snr_po_coh (answer)
    %% Coherence ("complex correlation"):
    flt_area = 1;  % in meters squared.
    flt_radius = sqrt(flt_area/pi);  % in meters.
    flt_radius_in_pixels = flt_radius ./ mean(answer.info.step);
    flt_kernel = fspecial('disk', flt_radius_in_pixels);
    filterit = @(in) filter2(flt_kernel, in, 'same');
    %ref = answer.net.phasor;
    %ref = answer.direct.phasor;
    ref = answer.phasor_direct;
    num = filterit(ref .* conj(answer.map.phasor));
    den = sqrt( get_power(ref) .* filterit(get_power(answer.map.phasor)) );
    answer.map.coh = num ./ den;
end

