function varargout = permittivity_complex2realimag (perm, convention)
    if (nargin < 2),  convention = [];  end
    perm_real = real(perm);
    perm_imag = imag(perm);
    convention = get_phase_convention (convention);
    switch convention
    case 'physics',  % change nothing
    case 'engineering',  perm_imag = -perm_imag;
    end
    switch nargout
    case {0, 1}
        varargout = {[perm_real(:), perm_imag(:)]};
    case 2
        varargout = {perm_real, perm_imag};
    end
end

%!test
%! % permittivity_complex2realimag()
%! test('permittivity_realimag2complex')
