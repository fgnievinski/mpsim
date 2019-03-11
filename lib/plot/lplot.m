function hh = lplot(varargin)

%LPLOT PLOT function that cycles through different line styles.
%   LPLOT(X,Y) plots Y versus X just like the PLOT command but cycles
%   through 8 different line styles instead of colors (4 line styles x 2
%   line widths).  The axes LineStyleOrder is set to '-|:|--|-.' and axes
%   ColorOrder is set to [0 0 0].  Multiple data sets, accepted by PLOT,
%   are allowed. e.g. LPLOT(X1, Y1, X2, Y2, ...)
%
%   H = LPLOT(...) returns a vector of line handles.
%
%   Example:
%     x = 0:0.1:10;
%
%     y1 = 1.2 * sin(2 * x);
%     y2 = 0.7 * cos(0.7 * x);
%     y3 = y1 + y2;
%     y4 = y1 - y2;
%     y5 = y1 .* y2;
%     y6 = y2 - y1;
%
%     h = lplot(x, y1, x, y2, x, y3, x, y4, x, y5, x, y6);
%     legend(h, 'y1', 'y2', 'y3', 'y4', 'y5', 'y6', 0);
%
%   See also PLOT, LINE.
%
%   VERSIONS:
%     v1.0 - first version
%     v1.1 - added more linestyles
%     v1.2 - added option to specify LineStyleOrder
%     v1.3 - remove optional LineStyleOrder option. reset properties
%            afterwards.
%

%   Jiro Doke
%   Feb 2005

if nargin < 2
  error('Not enough inputs.');
end

if mod(nargin, 2) == 1 || any(cellfun('isclass', varargin, 'char'))
  error('Input must be numeric X, Y pairs');
end

% prepare axes
axh = newplot;
nextplot = get(axh, 'NextPlot');

% get current LineStyleOrder and ColorOrder
LSCO = get(axh, {'LineStyleOrder', 'ColorOrder'});

% set LineStyleOrder and ColorOrder
set(axh, 'LineStyleOrder', '-|:|--|-.', ...
  'ColorOrder', [0 0 0]);

% if the NextPlot property is 'replace', then PLOT will reset the
% LineStyleOrder and the ColorOrder properties.
% so change it to 'replacechildren'
if strcmpi(nextplot, 'replace')
  set(axh, 'NextPlot', 'replacechildren');
end

% plot
try
  h = plot(varargin{:});
catch
  s = lasterr;
  tmp = strfind(s, sprintf('\n'));
  error(s(tmp+1:end));
end

% if there are more than 4 lines, change the thickness of the lines
if length(h) > 4
  lw = get(h(1), 'linewidth');
  set(h([5:8:end, 6:8:end, 7:8:end, 8:8:end]), 'linewidth', lw * 4);
end

% restore NextPlot, LineStyleOrder, and ColorOrder
set(axh, {'NextPlot','LineStyleOrder', 'ColorOrder'}, {nextplot,LSCO{:}});

if nargout == 1
  hh = h;
end