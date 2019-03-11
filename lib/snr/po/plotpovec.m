function plotpovec (answer, img, N, s, in_color, prc, open_fig)
  if (nargin < 3) || isempty(N),  N = 0.5;  end
  if (nargin < 4) || isempty(s),  s = 10;  end
  if (nargin < 5) || isempty(in_color),  in_color = false;  end
  if (nargin < 6) || isempty(prc),  prc = 100;  end
  if (nargin < 7) || isempty(open_fig),  open_fig = true;  end
  quivernormal = @quiver;
  %quivercolor = @quiverc;
  quivercolor = @quiverc2wcmap;  % faster
  if in_color,  quiverwhich = quivercolor;  else  quiverwhich = quivernormal;  end
  indx = interp1(answer.info.x_domain, 1:numel(answer.info.x_domain), answer.info.x_domain(1):N:answer.info.x_domain(end), 'nearest');
  indy = interp1(answer.info.y_domain, 1:numel(answer.info.y_domain), answer.info.y_domain(1):N:answer.info.y_domain(end), 'nearest');
  [indx2, indy2] = meshgrid(indx, indy);
  ind = sub2ind(size(img), indy2(:), indx2(:));
  magn = abs(img);
  magn_original = magn;
  if (prc < 100)
    temp = prctile(magn(ind), 100-prc);
    %img(magn < temp) = 0;
    img(magn < temp) = NaN;
    %img(magn < temp) = temp;
  end
  if open_fig,  figure;  end
  hold on
  scatter(answer.map.x(ind), answer.map.y(ind), 1^2, getel(abs(magn_original), ind), 'filled')
  quiverwhich(...
    answer.map.x(ind), answer.map.y(ind), ...
    getel(imag(img), ind)*s, getel(real(img), ind)*s, ...
    0, 'k')
  %img = f(answer.map);
  %imagesc(answer.info.x_domain, answer.info.y_domain, img)
  set(gca, 'YDir','normal')
  axis equal
  xlim(answer.info.x_lim)
  ylim(answer.info.y_lim)
  grid on
  xlabel('East (m)')
  ylabel('North (m)')
  %set(gca, 'XTick',linspace(answer.info.x_domain(1),answer.info.x_domain(end),10+1))
  %set(gca, 'YTick',linspace(answer.info.y_domain(1),answer.info.y_domain(end),10+1))
  if isfield(answer.info, 'x_lim0') ...
  && isfield(answer.info, 'y_lim0')
    xlim(answer.info.x_lim0)
    ylim(answer.info.y_lim0)
  end
  maximize()
end

