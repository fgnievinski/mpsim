function [hod, num0] = mydatehod (epoch, epoch0)
%MYDATEHOD: Convert epoch to (decimal) hours of day (optionally, elapsed since beginning of a different day).
    if (nargin < 2),  epoch0 = [];  end
    [sod, num0] = mydatesod (epoch, epoch0);
    hod = sod ./ 3600;
end
