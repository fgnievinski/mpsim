function [epoch_std, year, std_year_len] = mydatestd (epoch)
%MYDATESTD: Convert epoch to standardized annual format.
% (useful for building monthly climatologies).
    std_year_len = mydatestd_aux();
    if (nargin < 1)
        epoch_std = [];
        year = [];
        return
    end
        
    temp = mydatevec(epoch);
    year = temp(:,1);
    [year_len, year_start] = mydatestd_aux(year);

    epoch_std = (epoch - year_start) ./ year_len .* std_year_len;
end

%!test
%! % mydatestd()
%! test('mydatestd_aux')

