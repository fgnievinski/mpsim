function year = mydateyearn (num)
%MYDATEYEARN: Convert epoch to (integer) year number.
    vec = mydatevec(num);
    year = vec(:,1);
end
