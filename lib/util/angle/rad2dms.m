function dms=rad2dms(rad)
%
% Function rad2dms
% ================
%
%       Converts angles in radians to the format gg.mmsssssssss
%
% Sintax
% ======
%
%       dms=rad2dms(rad)
%
% Input
% =====
%
%       rad -> angle in radians
%
% Output
% ======
%
%       dms -> angle in the format gg.mmsssssssss
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

dms=deg2dms(rad*180/pi);

end

%!test
%! dms = 90.3030;
%! deg = 90+(30+30/60)/60;
%! rad = deg*pi/180;
%! dms2 = rad2dms(rad);
%! myassert (dms2, dms, -1000*eps);

