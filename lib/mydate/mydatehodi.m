function num = mydatehodi (hod, epoch0)
%MYDATEHODI: Convert from (decimal) hour of day (to internal format), elapsed since the beginning of a given day.

    sod = hod * 3600;
    num = mydatesodi (sod, epoch0);
end
