function domain = linspaceout (min, max, step, side)
  if (nargin < 4) || isempty(side),  side = 'both';  end
  % make sure it over-bounds:
  left  = floor(min/step)*step;
  right =  ceil(max/step)*step;
  switch side
  case 'both'  % both sides overbound
    % do nothing
  case 'left'  % only left side overbounds
    if (right > max)
      right = right - step;  % move right side inside
    end
  case 'right'  % only right side overbounds
    if (left < min)
      left = left + step;  % move left side inside
    end
  case 'none'  % no side overbounds
    if (right > max)
      right = right - step;  % move right side inside
    end
    if (left < min)
      left = left + step;  % move left side inside
    end
  otherwise
    error('matlab:linspaceout:unkSide', 'Unknown side "%s".', side);
  end
  domain = left:step:right;
  %zero_cross = (min < 0 && 0 < max);
  %if zero_cross,  assert(any(domain==0));  end
end
