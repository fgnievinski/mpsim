function varargout = permittivity_complex2magnphase (perm)
    perm_magn = abs(perm);
    perm_phase = get_phase(perm);
    switch nargout
    case {0, 1}
        varargout = {[perm_magn(:), perm_phase(:)]};
    case 2
        varargout = {perm_magn, perm_phase};
    end
end

