function cond = convert_pemittivity_to_conductivity (perm_imag, freq)
    perm_vac = get_standard_constant('vacuum permittivity');
    %perm_imag = (cond / freq) / perm_vac;  % WRONG!
    freq_ang = 2*pi * freq;
    
    if ~isreal(perm_imag)
        perm_complex = perm_imag;
        perm_imag = imag(perm_complex);        
    end
    
    cond = perm_imag .* perm_vac .* freq_ang;
end

