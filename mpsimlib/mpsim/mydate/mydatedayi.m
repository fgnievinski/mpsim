function num = mydatedayi (day, is_diff)
%MYDATEDAYI: Convert from (decimal) days (to epoch interval in internal format).
    if (nargin < 2),  is_diff = [];  end
    num = mydateseci (day*(60*60*24), is_diff);
end
