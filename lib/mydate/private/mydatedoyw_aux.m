function [num, num0, wyear] = mydatedoyw_aux (varargin)
%MYDATEDOYW_AUX: Auxiliary function for day of water-year conversions.
    [num, year] = mydatedoy_aux (varargin{:});
    if isscalar(year),  year = year .* ones(size(num));  end
    mon = 10;
    mon = repmat(mon, size(num));
    yearb = year-1;  vec0b = [yearb mon];  num0b = mydatenum(vec0b);  wyearb = yearb + 1;
    yeara = year;    vec0a = [yeara mon];  num0a = mydatenum(vec0a);  wyeara = yeara + 1;
    idx = (num < num0a);
    num0 = setel(num0a, idx, num0b(idx));
    wyear = wyeara;  wyear(idx) = wyearb(idx);
end
