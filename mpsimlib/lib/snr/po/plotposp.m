function plotposp (answer, img, in_color, domain, fz_max)
  if (nargin < 3) || isempty(in_color),  in_color = false;  end
  if (nargin < 4) || isempty(domain),  domain = 1;  end
  if (nargin < 5) || isempty(fz_max),  fz_max = Inf;  end
  if ~isfield(answer.map, 'contiguous')
      answer.map.contiguous = (answer.map.fresnel_zone <= answer.info.fz_border);
  end
  ind = answer.map.ind_delay(answer.map.fresnel_zone(answer.map.ind_delay) < fz_max);
  temp = img(ind);
  figure
  if in_color
    temp2 = getel(answer.map.contiguous.*answer.map.fresnel_zone, ind);
    h = cline(real(temp), imag(temp), temp2);
      set(h, 'LineWidth',2)
      set(h, 'ZData',zeros(size(get(h, 'XData'))))
    h = colorbar;
      title(h, 'FZ')
  else
    plot(real(temp), imag(temp), '-k')
  end
  axis equal
  switch domain
  case 1
    xlim([-1,+1])
    ylim([-1,+1])
    set(gca, 'XTick',-1:0.5:+1)
    set(gca, 'YTick',-1:0.5:+1)
  case 2
    xlim([0,2])
    ylim([-1,+1])
    set(gca, 'XTick',0:0.5:2)
    set(gca, 'YTick',-1:0.5:+1)
  end
  if (domain == 1) || (domain == 2)
    h = [];
    h(1) = vline(0);
    h(2) = hline(0);
    set(h, 'Color',[1 1 1]*0.5), 
    h(3) = rectangle('Position',[-1 -1 +2 +2], 'Curvature',[1 1 ], 'LineWidth',1, 'LineStyle','-', 'EdgeColor',[1 1 1]*0.5);
    uistack(h, 'bottom')
  end
  grid on
  xlabel('Real')
  ylabel('Imaginary')
end

