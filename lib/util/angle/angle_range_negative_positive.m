function angle = angle_range_negative_positive (angle, tol)
    if (nargin < 2),  tol = [];  end  
    angle = angle_range_positive (angle, tol);  % remove e.g. 720, -200, etc.
    idx = (angle > 180);
    angle(idx) = angle(idx) - 360;
end

