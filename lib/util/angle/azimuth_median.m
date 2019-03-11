function azim = azimuth_median (azim, varargin)
    azim = azimuth_stat (azim, @nanmedian, varargin{:});
end

%!test
%! dir = 0;
%! apperture = 45;
%! n = 100;
%! azim = randint(dir-apperture/2, dir+apperture/2, n, 1);
%! azim = azimuth_range_positive (azim);
%! dir2 = azimuth_median (azim);
%! dir3 = mean (azim);
%! 
%! figure
%! subplot(4,1,1:3)
%!   hold on
%!   % (argument to polar() is angle w.r.t. to positive x-axis, 
%!   % in radians, increasing to the left; in contrast, azim is 
%!   % the angle w.r.t. positive y-axis, in degrees, increasing 
%!   % to the right.)
%!   polar(-pi/180*(azim-90), ones(n,1), '.k')
%!   polar([0; -pi/180*(dir -90)], [0; 1], '+-b')
%!   polar([0; -pi/180*(dir2-90)], [0; 1], 'o-b')
%!   polar([0; -pi/180*(dir3-90)], [0; 1], 'o-r')
%!   axis equal
%!   legend({'Samples','True','Smart','Naive'})
%!   grid on
%! subplot(4,1,4)
%!   hold on
%!   plot(azim, ones(n,1), '.k')
%!   plot(dir , 1, '+b')
%!   plot(dir2, 1, 'ob')
%!   plot(dir3, 1, 'or')
%!   axis equal
%!   grid on
%!   xlim([0,360]);  set(gca, 'XTick',0:90:360)

