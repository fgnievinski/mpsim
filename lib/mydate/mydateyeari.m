function out = mydateyeari (day, is_diff)
%MYDATEYEARI: Convert from (decimal) year (to epoch interval in internal format).
% 
% See also: mydateyearabsi

    if (nargin < 2),  is_diff = [];  end
    out = mydatedayi(day * 365.25, is_diff);
end
