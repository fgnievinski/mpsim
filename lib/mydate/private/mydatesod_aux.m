function num0 = mydatesod_aux (epoch, epoch0)
    if (nargin < 2),  epoch0 = [];  end
    if ischar(epoch0)
        switch lower(epoch0)
        case {'first','initial','min'}
            epoch0 = min(epoch);
            %epoch0 = epoch(1);
            %if isnan(epoch0)
            %    epoch0 = epoch(find(~isnan(epoch), 1, 'first'));
            %end
        case {'median','fixed','med','mid'}
            %epoch0 = median(epoch);  % WRONG!
            epoch0 = nanmedian(epoch);
        otherwise
            error('mydate:hod:badEpoch0', 'Unknown string epoch0="%s".', epoch0);
        end
    end
    if ~isempty(epoch0)
        num0 = mydatebod (epoch0);  % scalar
    else
        num0 = mydatebod (epoch);  % vector-valued
    end
end

%!test
%! % mydatesod_aux()
%! test('mydatesod')
%! test('mydatesodi')

