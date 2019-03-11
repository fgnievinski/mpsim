function phasor = phasor_init (amplitude, phase, convention)
    if (nargin < 3),  convention = [];  end
    if isscalar(amplitude) && ~isscalar(phase) 
        amplitude = repmat(amplitude, size(phase));
    end
    if ~isscalar(amplitude) && isscalar(phase) 
        phase = repmat(phase, size(amplitude));
    end
    phasor = amplitude;
    %if none(phase),  return;  end
    idx = (phase ~= 0);
    if none(idx(:)),  return;  end
    phasor(idx) = phasor_init_aux (amplitude(idx), phase(idx), convention);
end

function phasor = phasor_init_aux (amplitude, phase, convention)
    exponential = get_phase_inv (phase, convention);
    phasor = amplitude .* exponential;
end

