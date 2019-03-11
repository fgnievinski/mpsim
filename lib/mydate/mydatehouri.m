function num = mydatehouri (hour, is_diff)
%MYDATEHOURI: Convert from (decimal) hours (to epoch interval in internal format).
    if (nargin < 2),  is_diff = [];  end
    num = mydateseci (hour*(60*60), is_diff);
end
