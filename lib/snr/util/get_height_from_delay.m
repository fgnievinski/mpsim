function height = get_height_from_delay (delay, elev, dim)
%GET_HEIGHT_FROM_DELAY: Get equivalent reflector height.
% Input:
%   delay [meters]
%   elev [degrees]
% Output:
%   height_equiv [meters]
%   vertwavenum [degrees per meter]
% See also: get_height_from_phase

  if (nargin < 3),  dim = [];  end
  if isvector(elev)
      height = gradient_all(delay, 2*sind(elev));
      return;
  end
  if isempty(dim)
      if is_uniform(elev(:,2))
          dim = 2;
      elseif is_uniform(elev(:,1))
          dim = 1;
      else
          error('SNR:get_height_from_delay:badInp', ...
              'Unknown elevation variation dimension.');
      end
  end
  height = gradient_all(delay, 2*sind(elev), dim);
end
