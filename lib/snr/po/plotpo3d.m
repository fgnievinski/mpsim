function plotpo3d (answer, f, cmap, prc, m)
  if (nargin < 3) || isempty(cmap),  cmap = 'hsv';  end
  if (nargin < 4) || isempty(prc),  prc = 100;  end
  if (nargin < 5) || isempty(m),  m = 1;  end
  if isa(f, 'function_handle')
    img = f(answer.map);
    tit = func2str(f);
  else
    img = f;
    tit = '';
  end
  ind_x = 1:m:length(answer.info.x_domain);
  ind_y = 1:m:length(answer.info.y_domain);
  figure
  surf(answer.info.x_domain(ind_x), answer.info.y_domain(ind_y), ...
    img(ind_y,ind_x), ...
    repmat(0.35, [length(ind_y),length(ind_x),3]), ...
    'EdgeColor','none');
  xlabel('East (m)')
  ylabel('North (m)')
  %shading interp    
  lighting phong
  material dull
  camlight('headlight')
  camlight('right')
  camlight('left')
  %colorbar
  axis vis3d
  title(tit, 'Interpreter','none')
  grid on
  switch cmap
  case 'bwr'
      colormap_bwr_it(img)
      set(gca, 'CLim',[-1,+1]*prctile(abs(img(:)),prc))
  otherwise
      eval(sprintf('colormap(%s)', cmap));
  end
  temp = get(gca, 'DataAspectRatio');
  temp(1:2) = max(temp(1:2));
  set(gca, 'DataAspectRatio',temp);
  xlim(answer.info.x_lim)
  ylim(answer.info.y_lim)
  %zlim([0,1])
  maximize()
end

