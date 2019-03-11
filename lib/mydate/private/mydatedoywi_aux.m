function [wyear, num0] = mydatedoywi_aux (wyear)
%MYDATEDOYW_AUX: Auxiliary function for day of water-year conversions.
    if ischar(wyear)
        assert(numel(wyear) == 9)
        %assert(wyear(5) == '-')
        year1 = str2double(wyear(1:4));
        year2 = str2double(wyear(6:9));
        assert(year1 == (year2-1))
        wyear = year2;  % "The water year is designated by the calendar year in which it ends."
    end
    if (nargout < 2),  return;  end
    vec0 = wyear - 1;  vec0(:,2) = 10;
    num0 = mydatenum(vec0);
end
