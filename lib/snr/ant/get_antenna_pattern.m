function [phasor_rhcp, phasor_lhcp] = get_antenna_pattern (elev, azim, ant)
    ant = get_antenna_pattern_fnc (ant);
    if isscalar(azim),  azim = repmat(azim, size(elev));  end
    phasor_rhcp = get_antenna_pattern_aux (elev, azim, ant, 'rhcp');
    if (nargout < 2),  return;  end
    phasor_lhcp = get_antenna_pattern_aux (elev, azim, ant, 'lhcp');
end

function [phasor, ampl, phase] = get_antenna_pattern_aux (elev, azim, ant, polar_name)
    ampl   = ant.gain.eval  (elev, azim, polar_name);
    phase  = ant.phase.eval (elev, azim, polar_name);
    phasor = phasor_init(ampl, phase);
    phasor = conj(phasor);  % conjugate now so that user only have to multiply and add.
end

