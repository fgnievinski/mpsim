function [height, vertwavenum] = get_height_from_phase (phase, elev, wavelen, algorithm)
%GET_HEIGHT_FROM_PHASE: Get equivalent reflector height.
% Input:
%   phase (unwrapped) [degrees]
%   elev [degrees]
%   wavelen [meters]
% Output:
%   height [meters]
%   vertwavenum [degrees per meter]
  if (nargin < 4) || isempty(algorithm),  algorithm = 1;  end
  wavenum = 2*pi./wavelen;  % textbook definition of wavenumber.
  wavenum = wavenum * 180/pi;  % our convention is phase in degrees.
  switch algorithm
  case 1
    delay = phase ./ wavenum;
    height = get_height_from_delay (delay, elev);
    if (nargout < 2),  return;  end
    vertwavenum = 2*wavenum*sind(elev);  % vertical wavenumber.
  case 2
    vertwavenum = 2*wavenum*sind(elev);  % vertical wavenumber.
    %height = gradient(phase, vertwavenum);
    height = gradient_all(phase, vertwavenum);
  end
end

%!test
%! input = {(1:10)', linspace(20, 40, 10)', 0.24};
%! [height0, vertwavenum] = get_height_from_phase (input{:});
%! [height1, vertwavenum] = get_height_from_phase (input{:}, 1);
%! [height2, vertwavenum] = get_height_from_phase (input{:}, 2);
%!   %[height0 height1 height2]  % DEBUG
%! myassert(height0, height1, -sqrt(eps()))
%! myassert(height0, height2, -sqrt(eps()))
