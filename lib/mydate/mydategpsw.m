function varargout = mydategpsw (epoch, second_output_type)
%MYDATEGPSW: Convert epoch to GPS week (and optionally day and second):
% - decimal week; or 
% - integer week number and decimal second of week; or
% - integer week number, integer day of week number, and decimal second of day.
% The second input argument selects the type of the second output argument: 
% - 'sow': decimal second of week (default);
% - 'dow': decimal day of week.
    if (nargin < 2) || isempty(second_output_type),  second_output_type = 'sow';  end
    error(nargoutchk(0, 3, nargout, 'struct'));
    [epoch0, sec_per_week, sec_per_day] = mydategpsw_aux ();
    week = mydatesec(epoch - epoch0) ./ sec_per_week;
    if (nargout < 2),  varargout = {week};  return;  end
    weeknum = floor(week);
    sow = (week - weeknum) .* sec_per_week;
    if (nargout < 3) && strcmp(second_output_type, 'sow'),  varargout = {weeknum, sow};  return;  end
    dow = sow ./ sec_per_day;
    if (nargout < 3) && strcmp(second_output_type, 'dow'),  varargout = {weeknum, dow};  return;  end
    downum = floor(dow);
    % take ceiling instead of floor if it's close to machine precision:
    idx = (dow - downum - 1) < sqrt(eps());
    downum(idx) = downum(idx) + 1;    
    sod = sow - downum .* sec_per_day;
    varargout = {weeknum, downum, sod};
end

%!test
%! % mydategpsw()
%! test mydategpswi
