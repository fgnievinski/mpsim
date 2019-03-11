function [jacob, colname] = mplsqfourier_design (elev, peak, degree, exclude_height)
    if (nargin < 3),  degree = [];  end
    if (nargin < 4),  exclude_height = [];  end
    
    sine = sind(elev);
    [jacob, colname] = lsqfourier_design (sine, peak, degree, exclude_height);
end

