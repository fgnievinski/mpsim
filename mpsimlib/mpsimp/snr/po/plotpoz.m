function h = plotpoz (answer, data, cmap, prc, map, units, overlay_lines, zero_centered)
  if (nargin < 3) || isempty(cmap),  cmap = 'hsv';  end
  if (nargin < 4) || isempty(prc),  prc = 100;  end
  if (nargin < 5) || isempty(map),  map = 'map';  end
  if (nargin < 6),  units = [];  end
  if (nargin < 7) || isempty(overlay_lines),  overlay_lines = true;  end
  if (nargin < 8) || isempty(zero_centered),  zero_centered = false;  end
  if any(strcmp(cmap, {'bwr','dkbluered'})),  zero_centered = true;  end
  assert(isscalar(answer))
  if isfield(answer, 'info')
      % legacy interface:
      answer = structmerge(answer, answer.info);
  end
  
%   switch nargin(f)
%   case 1
%     img = f(answer.(map));
%   case 2
%     img = f(answer.(map), answer);
%   end
  %img = complex2rgb(data, 5);
  img = complex2rgb(data, 8);

  figure
  h=image(answer.(map).x_domain, answer.(map).y_domain, img);
  %set(h, 'AlphaData',~isnan(img))
  set(gca, 'YDir','normal')
  %h(1) = colorbar;
  %if ~isempty(units),  title(h(1), sprintf('(%s)', units));  end
  axis image
%  title(func2str(f), 'Interpreter','none')
  grid on
  xlabel('East (m)')
  ylabel('North (m)')
%   set(gca, 'XTick',linspace(answer.(map).x_domain(1),answer.(map).x_domain(end),10+1))
%   set(gca, 'YTick',linspace(answer.(map).y_domain(1),answer.(map).y_domain(end),10+1))
  
  if overlay_lines
    hold on
    for i=1:2
      fz = get_fresnel_zone (answer.height_ant, answer.elev, answer.azim, answer.wavelength, i/2, [], []);
      plot(fz.x, fz.y, 'w-', 'LineWidth',3)
      plot(fz.x, fz.y, 'k-', 'LineWidth',2)
    end
    pos_refl = get_specular_reflection (answer.height_ant, answer.elev, answer.azim);
    plot(pos_refl(2), pos_refl(1), 'w+', 'MarkerSize',12, 'LineWidth',4)
    plot(pos_refl(2), pos_refl(1), 'k+', 'MarkerSize',8, 'LineWidth',2)
    plot(0, 0, 'wo', 'MarkerSize',7, 'MarkerFaceColor','w')
  end
  if (nargout < 1),  clear h;  end
end

