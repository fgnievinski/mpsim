function out = snr_po_mapform (in, siz2, idx_keep2)
    persistent siz idx_keep
    if (nargin < 1),  siz = [];  idx_keep = [];  return;  end
    if (nargin > 1) && ~isempty(siz2),  siz = siz2;  end
    if (nargin > 2) && ~isempty(idx_keep2),  idx_keep = idx_keep2;  end
    if isempty(in) || isscalar(in),  out = in;  return;  end
    if ~isempty(idx_keep),  in = setel(NaN(siz), idx_keep, in);  end
    out = reshape(in, siz);
end
%function out = snr_po_mapform (in, siz2)
%    persistent siz
%    if isempty(siz),  siz = siz2;  end
%    if isempty(in) || isscalar(in),  out = in;  return;  end
%    out = reshape(in, siz);
%end

