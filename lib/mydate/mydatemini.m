function num = mydatemini (min, is_diff)
%MYDATEMINI: Convert from (decimal) minutes (to epoch interval in internal format).
    if (nargin < 2),  is_diff = [];  end
    num = mydateseci (min*60, is_diff);
end
