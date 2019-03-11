function varargout = plotsininv (E, Y, varargin)
  Defaults = struct();
  Defaults.LineSpec = '-';
  Defaults.etick = 0:5:90;
  Defaults.eticktolabel = [0:1:10 15 20 30 45 90];
  Defaults.format = '%.1f';
  Defaults.xlabel = 'Elevation angle (degrees)';
  [Unmatched, Results] = plotsinaux2 (Defaults, varargin{:});
  
  temp = struct2pv(Unmatched);
  [varargout{1:nargout}] = plot(1./sind(E), Y, Results.LineSpec, temp{:});
  
  %Results.etick = Results.etick
%   if ischar(eticktolabel),  switch lower(eticktolabel)
%   case 'full',  eticktolabel = [0:1:10 15 20 30 60 90];
%   case 'wide',  eticktolabel = 0:15:90;
%   case 'avg',   eticktolabel = [0:10:60,90];
%   otherwise,  error('MATLAB:set_tick_label_asind2:badLab', ...
%       'Unknown eticktolabel = "%s"', eticktolabel);
%   end,  end
  
  set_xtick_label_asind2 (Results.format, Results.etick, Results.eticktolabel, ...
    [5 90], @(x) 1./sind(x));
%   
%   xlabel(Results.xlabel)

  set(gca(), 'XDir','reverse')
end
