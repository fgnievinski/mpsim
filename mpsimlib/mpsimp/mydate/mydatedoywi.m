function [num, wyear] = mydatedoywi (doyw, wyear)
%MYDATEDOYWI: Convert from (decimal) day of water-year (to epoch internal format).
    [wyear, num0] = mydatedoywi_aux (wyear);
    myassert(length(wyear)==length(doyw) || isscalar(wyear) || isempty(doyw))
    num = num0 + mydatedayi(doyw);
end

%!test
%! % mydatedoywi()
%! test mydatedoyw

%!test
%! myassert(mydatedoywi(1, '2009-2010'), mydatedoywi(1, 2010))

