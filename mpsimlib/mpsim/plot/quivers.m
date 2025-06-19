function hq = quivers (x, y, u, v, varargin)
  hq = quiver(x, y, u, v, varargin{:});
  setappdata(hq, 'UDataOriginal',u);
  setappdata(hq, 'VDataOriginal',v); 
  quivers_update (hq);
  
  temp = {@(src, eventdata) quivers_update(hq)};
  set(gcf(), 'ResizeFcn',temp);
  set(zoom(),'ActionPostCallback',temp);
  set(pan(),'ActionPostCallback',temp);
  
  if (nargout < 1),  clear hq;  end
end

%%
function quivers_update (hq)
  s = daspect();
  set(hq, ...
    'UData',s(1)*getappdata(hq,'UDataOriginal'), ...
    'VData',s(2)*getappdata(hq,'VDataOriginal'));
end

%%
%!test
%! n = 25;
%! x = linspace(0, 1, n);
%! y = zeros(1, n);
%! ang = linspace(0, 2*pi, n);
%! [u,v] = pol2cart(ang, 1);
%! figure
%! quivers(x, y, u, v, 'Marker','o', 'ShowArrowHead','off');
%! grid on

%TODO: compare to annotations
% annotations = @(type, X, Y, varargin) cellfun(@(x, y) annotation(type, x, y, varargin{:}), ...
%   mat2cell(X,ones(size(X,1),1)), mat2cell(Y,ones(size(Y,1),1)));
% clip01 = @(X) min(max(X, 0), 1);
% annotations = @(type, X, Y, varargin) annotations(type, clip01(X), clip01(Y), varargin{:});

