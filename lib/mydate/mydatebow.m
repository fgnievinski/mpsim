function bow2 = mydatebow (epoch2)
%MYDATEBOW: Return epoch at beginning of the week containing input epoch.

    % beginning of day:
    epoch2_vec = mydatevec(epoch2);
    bod2_vec = epoch2_vec;  bod2_vec(:,4:6) = 0;
    bod2 = mydatenum(bod2_vec);

    % beginning of week:
    %weekday(datenum(bod2_vec))-1  % DEBUG
    bow2 = bod2 - (weekday(datenum(bod2_vec))-1)*24*3600;
end

%!test
%! % mydatebow()
%! test('mydatesow')
%! test('mydatesowi')

