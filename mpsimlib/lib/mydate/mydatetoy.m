function [toy, year] = mydatetoy (varargin)
%MYDATETOY: Convert epoch to (decimal) multiples of twelfth of a year.
    [num, year] = mydatedoy_aux (varargin{:});
    num0 = mydatenum(year);
    dnum = num - num0;
    toy = mydatetwe (dnum);
end
