function varargout = plotsin (E, Y, varargin)
  [Unmatched, Results] = plotsinaux (varargin{:});
  
  temp = struct2pv(Unmatched);
  [varargout{1:nargout}] = plot(sind(E), Y, Results.LineSpec, temp{:});
  
  set_xtick_label_asind2 (Results.format, Results.etick, Results.eticktolabel);
  
  xlabel(Results.xlabel)
end

%!test
%! opt1 = {...
%!   {};
%!   {'.-r'};
%!   {'.-r', 'LineWidth',2};
%!   {'.-r', 'LineWidth',2, 'Marker','o'};
%! };
%! opt2 = {...
%!   {};
%!   {'etick',[0 45 90]};
%!   {'etick',[0 45 90], 'eticktolabel',45};
%!   {'etick',[0 45 90], 'eticktolabel','avg'};
%!   {'etick',[0 45 90], 'eticktolabel','wide'};
%! };
%! 
%! figure
%! for i=1:numel(opt1)
%! for j=1:numel(opt2)
%!   plotsin(0:90, 0:90, opt1{i}{:}, opt2{j}{:})
%!   % pause()  % DEBUG
%! end
%! end
%! close(gcf())
