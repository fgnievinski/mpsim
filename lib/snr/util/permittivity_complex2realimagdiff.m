function [perm_real, perm_imag] = permittivity_complex2realimagdiff (perm)
    [perm_real, perm_imag] = permittivity_complex2realimag (perm);
    perm_real = permittivity_realdiff (perm_real);
end
