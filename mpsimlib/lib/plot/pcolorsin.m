function varargout = pcolorsin (E, X, Y, varargin)
  [Unmatched, Results] = plotsinaux (varargin{:});
  
  temp = struct2pv(Unmatched);
  [varargout{1:nargout}] = pcolor(sind(E), X, Y, temp{:});
  
  set_xtick_label_asind2 (Results.format, Results.etick, Results.eticktolabel);
  
  xlabel(Results.xlabel)
end
