function num = mydatetoyi (toy, year0)
%MYDATETOYI: Convert from (decimal) multiples of twelfth of a year (to epoch internal format).
    if (nargin < 2) || isempty(year0),  year0 = getel(datevec(now()), 1);  end
    myassert(length(year0)==length(toy) || isscalar(year0))
    num0 = mydatenum(year0);  % epoch corresponding to the beginning to that year.
    dnum = mydatetwei(toy);
    num = num0 + dnum;
end
