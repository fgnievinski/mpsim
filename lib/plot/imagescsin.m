function varargout = imagescsin (E, Y, Z, varargin)
  [Unmatched, Results] = plotsinaux (varargin{:});
  
  temp = struct2pv(Unmatched);
  [varargout{1:nargout}] = imagesc(sind(E), Y, Z, temp{:});
  
  set_xtick_label_asind2 (Results.format, Results.etick, Results.eticktolabel);
  
  xlabel(Results.xlabel)
end
