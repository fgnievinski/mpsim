function diff = azimuth_diff (azim1, azim2, discard_sign)
    if (nargin < 2),  azim2 = [];  end
    if (nargin < 3) || isempty(discard_sign),  discard_sign = false;  end
    if isempty(azim2)
        diff = azimuth_diff1 (azim1);
    else
        diff = azimuth_diff2 (azim1, azim2);
    end
    if ~discard_sign,  return;  end
    diff = abs(diff);
end

function diff = azimuth_diff1 (azim)
    assert(isvector(azim))
    azima = azim(1:end-1);
    azimb = azim(2:end);
    diff = azimuth_diff2 (azimb, azima);
    %diff = azimuth_diff2 (azima, azimb);  % WRONG!
end

function diff = azimuth_diff2 (azim1, azim2)
    diff = azim1 - azim2;
    idx = (diff > +180);  diff(idx) = diff(idx) - 360;
    idx = (diff < -180);  diff(idx) = diff(idx) + 360;
end

%!test
%! temp = [...
%!     100   0  100
%!     100 -10  110
%!     100 +10   90
%!       0 100 -100
%!     -10 100 -110
%!     +10 100  -90
%!     350 100 -110
%!    -350 100  -90
%! ];
%! azim1 = temp(:,1);
%! azim2 = temp(:,2);
%! diff  = temp(:,3);
%! diffb = azimuth_diff (azim1, azim2);
%! [azim1, azim2, diff, diffb, diffb-diff]  % DEBUG
%! myassert(diffb, diff)

