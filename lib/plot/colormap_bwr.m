% (this is just an interface)
function c = colormap_bwr (m)
    if (nargin < 1),  m = [];  end
    c = bwr (m);
end

