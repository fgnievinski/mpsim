function mon = mydatemoyn (num)
%MYDATEMOYN: Convert epoch to (integer) month of year number.
    vec = mydatevec(num);
    mon = vec(:,2);
end
