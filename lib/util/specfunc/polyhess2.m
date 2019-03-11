function [dz2_dx2, dz2_dy2, dz2_dxy] = polyhess2 (c, x, y, cdx2, cdy2, cdxy)
    if (nargin < 4) || isempty(cdx2) ...
    || (nargin < 5) || isempty(cdy2) ...
    || (nargin < 6) || isempty(cdxy)
        cs = polyhess2_aux (c);
    else
        cs = struct('c',c, 'cdx2',cdx2, 'cdy2',cdy2, 'cdxy',cdxy);
    end
    dz2_dx2 = polyval2 (cs.cdx2, x, y);
    dz2_dy2 = polyval2 (cs.cdy2, x, y);
    dz2_dxy = polyval2 (cs.cdxy, x, y);
end

