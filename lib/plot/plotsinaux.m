function [Unmatched, Results] = plotsinaux (varargin)
  Defaults = struct();
  Defaults.LineSpec = '-';
  Defaults.etick = 10/4;
  Defaults.eticktolabel = 'full';
  Defaults.format = '%.1f';
  Defaults.xlabel = 'Elevation angle (degrees)';
  [Unmatched, Results] = plotsinaux2 (Defaults, varargin{:});
end
