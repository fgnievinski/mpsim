function phasor = get_phase_inv (phase, convention)
    if (nargin < 2),  convention = [];  end
    if isa(phase, 'sym'),  phasor = get_phase_inv_aux(phase);  return;  end    
    phasor = ones(size(phase));
    idx = (phase ~= 0);
    if none(idx(:)),  return;  end
    phasor(idx) = get_phase_inv_aux(phase(idx), convention);
end

function phasor = get_phase_inv_aux (phase, convention)
    % the sign convention needs to be consistent with that of 
    %   permittivity_realimag2complex, permittivity_complex2realimag;
    convention = get_phase_convention (convention);
    s = 1;
    switch convention
    case 'physics',  % change nothing.
    case 'engineering',  s = -1;
    end
    phasor = exp(s*1i*pi/180*phase);
end

%!test
%! % get_phase_inv()
%! test('permittivity_realimag2complex')
