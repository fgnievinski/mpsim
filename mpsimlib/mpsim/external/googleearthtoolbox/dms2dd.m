function dd = dms2dd(d,m,s)
%converts degrees-minutes-seconds notation to decimal degrees
a=sign(d);
dd = sum([d,a*m,a*s]./[1,60,3600]);