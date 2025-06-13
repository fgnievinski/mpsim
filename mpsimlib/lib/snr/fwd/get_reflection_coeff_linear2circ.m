function [phasor_same, phasor_cross] = get_reflection_coeff_linear2circ (...
phasor_perp, phasor_paral)
    % se Vaughan and Andersen, eq.(3.1.22), p.94:
    phasor_same  = (phasor_paral + phasor_perp) ./ 2;
    phasor_cross = (phasor_paral - phasor_perp) ./ 2;
end

