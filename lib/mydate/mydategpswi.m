function epoch = mydategpswi (varargin)
%MYDATEGPSWI: Convert from GPS week (and optionally day and second).
    [epoch0, sec_per_week, sec_per_day] = mydategpsw_aux ();
    switch nargin
    case 1
        week = varargin{1};
        depoch = week .* sec_per_week;
        epoch = epoch0 + depoch;
        return
    case 2
        [weeknum, sow] = deal(varargin{:});
    case 3
        [weeknum, dow, sod] = deal(varargin{:});
        sow = dow .* sec_per_day + sod;
    end
    bow = epoch0 + mydateseci(weeknum .* sec_per_week);
    epoch = bow + mydateseci(sow);
end

%!test
%! % using SOPAC's date converter:
%! % <http://sopac.ucsd.edu/scripts/convertDate.cgi>
%! for i=1:3
%!   switch i
%!   case 1
%!     year = 2009;
%!     mon = 10;
%!     day = 28;
%!     week = 1555;
%!     dow = 3;
%!     sod = 100*rand;
%!   case 2
%!     year = 2000;
%!     mon = 01;
%!     day = 01;
%!     week = 1042;
%!     dow = 6;
%!     sod = 100*rand;
%!   case 3
%!     year = 2010;
%!     mon = 06;
%!     day = 05;
%!     week = 1586;
%!     dow = 6;
%!     sod = 0;
%!   end
%!   vec = [year, mon, day, 0, 0, sod];
%!   num = mydatenum(vec);
%!   [weeknum2a, downum2a, sod2a] = mydategpsw (num);
%!   [weeknum2b, sow2b] = mydategpsw (num);
%!   week2c = mydategpsw (num);
%!   num2a = mydategpswi (weeknum2a, downum2a, sod2a);
%!   num2b = mydategpswi (weeknum2b, sow2b);
%!   num2c = mydategpswi (week2c);
%!    %[ [weeknum2a, downum2a, sod2a];  [week, dow, sod]; ...
%!    %  [weeknum2a, downum2a, sod2a] - [week, dow, sod] ]  % DEBUG
%!    %[num, num2a, num2a-num]
%!    %[num, num2b, num2b-num]
%!    %[num, num2c, num2c-num]
%!   myassert(weeknum2b, week);
%!   myassert(weeknum2a, week);
%!   myassert(downum2a, dow);
%!   myassert(sod2a, sod, -10*sqrt(eps(max(1,sod))));
%!   myassert(num2a, num, -10*sqrt(eps(max(1,sod))));
%!   myassert(num2b, num, -10*sqrt(eps(max(1,sod))));
%!   myassert(num2c, num, -10*sqrt(eps(max(1,sod))));
%! end

