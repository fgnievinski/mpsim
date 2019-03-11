function phase = get_phase (phasor, convention)
    if (nargin < 2),  convention = [];  end
    phase = 180/pi * angle(phasor);
    convention = get_phase_convention (convention);
    switch convention
    case 'physics',  % change nothing.
    case 'engineering',  phase = -phase;
    end
end

%!test
%! % get_phase
%! test('get_phase_inv')
