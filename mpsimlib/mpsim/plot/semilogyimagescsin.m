function varargout = semilogyimagescsin (E, Y, Z, varargin)
  [Unmatched, Results] = plotsinaux (varargin{:});
  
  temp = struct2pv(Unmatched);
  [varargout{1:max(1,nargout)}] = pcolor(sind(E), Y, Z, temp{:});
  set(varargout{1}, 'EdgeColor','none')
  varargout = varargout(1:nargout);
    
  set_xtick_label_asind2 (Results.format, Results.etick, Results.eticktolabel);
  xlabel(Results.xlabel)
  
  %axis image
  axis tight
  set(gca(), 'YScale','log')
end
