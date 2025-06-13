function out = mydateseci (sec, is_diff, factor)
%MYDATESECI: Convert from (decimal) seconds (to epoch interval in internal format).
    %if (nargin < 2) || isempty(is_diff),  is_diff = false;  end  % WRONG!
    if (nargin < 2) || isempty(is_diff),  is_diff = true;  end
    if (nargin < 3) || isempty(factor),  factor = 60*60*24;  end
    [factor0, num0] = mydatebase ();
    out = sec;
    if (factor0 ~= factor),  out = out .* (factor0 / factor);  end
    if ~is_diff,  out = out + num0;  end
end
