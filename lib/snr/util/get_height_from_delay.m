function height = get_height_from_delay (delay, elev)
%GET_HEIGHT_FROM_DELAY: Get equivalent reflector height.
% Input:
%   delay [meters]
%   elev [degrees]
% Output:
%   height_equiv [meters]
%   vertwavenum [degrees per meter]
  %height = gradient(delay, 2*sind(elev));
  height = gradient_all(delay, 2*sind(elev));
end
