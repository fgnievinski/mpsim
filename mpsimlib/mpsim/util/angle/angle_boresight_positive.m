function [angp, azim] = angle_boresight_positive (ang, azi)
    % convert boresight angle domain, from +/-180 to 0-180, modifying azimuth if necessary.
    
    %whos ang azi  % DEBUG    
    assert(all(abs(ang) <= 360));
    m = numel(ang);
    angp = NaN(m,1);
    azim = NaN(m,1);
    idx2 = NaN(m,1);

    idx = (0 <= ang & ang < 180);
    angp(idx) = ang(idx);
    azim(idx) = azi(idx);
    idx2(idx) = true;

    idx = (-180 <= ang & ang < 0);
    angp(idx) = abs(ang(idx));
    azim(idx) = azi(idx) + 180;
    idx2(idx) = true;

    idx = (180 <= ang & ang <= 360);
    angp(idx) = abs(ang(idx) - 360);
    azim(idx) = azi(idx) + 180;
    idx2(idx) = true;

    idx = (-360 <= ang & ang < -180);
    angp(idx) = 360 + ang(idx);
    azim(idx) = azi(idx) + 180;
    idx2(idx) = true;
    
    assert(all(idx2))  % visited.
end

%!test
%! ang = [5 -5 355 179 -179 181]';
%! azi = [0 0 0 0 0 0]';
%! angp = [5 5 5 179 179 179]';
%! azim = [0 180 180 0 180 180]';
%! ind = [1 2 2 3 4 4]';
%! 
%! [angp2, azim2] = angle_boresight_positive (ang, azi);
%! 
%! %[angp angp2]  % DEBUG
%! %[azim azim2]  % DEBUG
%! %[ang azi angp azim angp2 azim2]  % DEBUG
%! myassert(angp, angp2)
%! myassert(azim, azim2)
%! 
%! elev = 90 - angp;
%! cart = convert_local_sph2cart ([elev, azim]);
%! ind2 = unique(ind);
%! for i=1:numel(ind2)
%!   carti = cart(ind==ind2(i),:);
%!   assert(size(unique(carti, 'rows'),1) == 1)
%! end
