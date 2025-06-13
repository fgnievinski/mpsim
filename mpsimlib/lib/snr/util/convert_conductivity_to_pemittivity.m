function perm_imag = convert_conductivity_to_pemittivity (cond, freq)
    perm_vac = get_standard_constant('vacuum permittivity');
    %perm_imag = (cond / freq) / perm_vac;  % WRONG!
    freq_ang = 2*pi * freq;
    
    perm_imag = (cond ./ freq_ang) ./ perm_vac;
end

