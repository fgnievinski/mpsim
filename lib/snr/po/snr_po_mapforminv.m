function out = snr_po_mapforminv (in, idx_keep2)
    persistent idx_keep
    if (nargin < 1),  idx_keep = [];  return;  end
    if (nargin > 1) && ~isempty(idx_keep2),  idx_keep = idx_keep2;  end
    if isempty(in) || isscalar(in),  out = in;  return;  end
    if ~isempty(idx_keep),  in = in(idx_keep);  end
    out = in(:);
end
% function out = snr_po_mapforminv (in)
%     out = in(:);
% end
%function out = snr_po_mapforminv (in, num_elements2)
%    persistent num_elements
%    if isempty(num_elements),  num_elements = num_elements2;  end
%    if isempty(in) || isscalar(in),  out = in;  return;  end
%    out = reshape(in, [num_elements,1]);
%end


