function perm_real = permittivity_realdiff (perm_real)
    %perm_real = max(perm_real, 1);
    perm_real(perm_real < 1) = 1;
    %perm_real = 1 + abs(perm_real - 1);
    %perm_real(perm_real < 1) = sqrt(realmax());
    %perm_real(perm_real < 1) = 100;
    %perm_real(perm_real < 1) = nthroot(realmax(),3);
end
