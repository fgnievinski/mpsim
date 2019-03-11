function azim = azimuth_mean (azim, varargin)
    azim = azimuth_stat (azim, @nanmean, varargin{:});
end

%!test
%! dir = 0;
%! apperture = 45;
%! n = 100;
%! azim = randint(dir-apperture/2, dir+apperture/2, n, 1);
%! idx = (azim < 0);  azim(idx) = 360 + azim(idx);
%!   myassert(all(azim <= 360))
%! dir2 = azimuth_mean (azim);
%! dir3 = mean (azim);
%! figure
%! hold on
%! % (argument to polar() is angle w.r.t. to positive x-axis, 
%! % in radians, increasing to the left; in contrast, azim is 
%! % the angle w.r.t. positive y-axis, in degrees, increasing 
%! % to the right.)
%! polar(-pi/180*(dir -90), 1, '+b')
%! polar(-pi/180*(azim-90), ones(n,1), '.k')
%! polar(-pi/180*(dir2-90), 1, 'ob')
%! polar(-pi/180*(dir3-90), 1, 'or')
%! axis equal
%! figure
%! hold on
%! plot(dir , 1, '+b')
%! plot(azim, ones(n,1), '.k')
%! plot(dir2, 1, 'ob')
%! plot(dir3, 1, 'or')
%! axis equal

%!test
%! out = azimuth_mean([3 4; 5 6], 2)
%! myassert(out, [3.5; 5.5], -sqrt(eps()))
%! out = azimuth_mean([3 4; 5 6], 1)
%! myassert(out, [4 5], -sqrt(eps()))
