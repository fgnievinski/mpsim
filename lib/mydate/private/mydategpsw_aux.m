function [epoch0, sec_per_week, sec_per_day] = mydategpsw_aux ()
    %epoch0 = mydatenum([1980 01 13]);  % WRONG!
    epoch0 = mydatenum([1980 01 06]);
    % as per <http://facility.unavco.org/data/glossary.html#GPS week>
    sec_per_hour = 60^2;
    sec_per_day  = 24 * sec_per_hour;
    sec_per_week = 7 * sec_per_day;
end
