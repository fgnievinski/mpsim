function rad=dms2rad(dms)
%
% Function dms2rad
% ================
%
%       Converts angles in the format gg.mmsssssssss to radians
%
% Sintax
% ======
%
%       rad=dms2rad(dms)
%
% Input
% =====
%
%       dms -> angle in the format gg.mmsssssssss
%
% Output
% ======
%
%       rad -> angle in radians
%
% Created/Modified
% ================
%
% When          Who                     What
% ----          ---                     ----
% 2006/06/28    Rodrigo Leandro         Function created
%
%
% ==============================
% Copyright 2006 Rodrigo Leandro
% ==============================

rad=dms2deg(dms)*pi/180;

end

%!test
%! dms = 90.3030;
%! deg = 90+(30+30/60)/60;
%! rad = deg*pi/180;
%! rad2 = dms2rad(dms);
%! myassert (rad2, rad, -1000*eps);

