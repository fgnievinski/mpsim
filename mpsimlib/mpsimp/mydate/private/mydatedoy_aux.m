function [num, year] = mydatedoy_aux (epoch, year)
%MYDATEDOY_AUX: Auxiliary function for day of year conversions.
    if (nargin < 2),  year = [];  end
    if isempty(epoch)
        %siz = [0 0];  % WRONG! would trigger 'MATLAB:dimagree'
        siz = size(epoch);
        num = ones(siz);
        year = ones(siz);
        return;
    end
    if (size(epoch,2) == 1)
        % epoch is in mydatenum format
        num = epoch;
        vec = mydatevec(num);
    else
        % epoch is in mydatevec format
        vec = epoch;
        num = mydatenum(vec);
    end
    clear epoch

    %% now define the epoch corresponding to the beginning to that year:
    if isempty(year),  year = vec(:,1);  end
    if ~ischar(year),  return;  end
    switch lower(year)
    case {'first','initial','min'}
        year = min(vec(:,1));
    case {'median','fixed','med','mid'}
        %year = median(vec(:,1));  % WRONG!
        year = nanmedian(vec(:,1));
        year = round(year);
    otherwise
        error('mydate:doy:badYear', 'Unknown character year="%s".', year);
    end
end

