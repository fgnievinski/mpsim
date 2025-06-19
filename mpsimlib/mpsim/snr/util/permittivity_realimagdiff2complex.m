function perm = permittivity_realimagdiff2complex (perm_real, perm_imag)
    perm_real = permittivity_realdiff (perm_real);
    perm = permittivity_realimag2complex (perm_real, perm_imag);
end
