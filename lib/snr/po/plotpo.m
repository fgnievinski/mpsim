function [h, ch] = plotpo (answer, f, cmap, prc, map, units, overlay_lines, zero_centered, is_phase)
  if (nargin < 3) || isempty(cmap),  cmap = 'hsv';  end
  if (nargin < 4) || isempty(prc),  prc = 100;  end
  if (nargin < 5) || isempty(map),  map = 'map';  end
  if (nargin < 6),  units = [];  end
  if (nargin < 7) || isempty(overlay_lines),  overlay_lines = true;  end
  if (nargin < 8) || isempty(zero_centered),  zero_centered = false;  end
  if (nargin < 9) || isempty(is_phase),  is_phase = false;  end
  if any(strcmp(cmap, {'bwr','dkbluered'})),  zero_centered = true;  end
  if strcmp(cmap, 'hsv'),  is_phase = true;  end
  assert(isscalar(answer))
  if isfield(answer, 'info')
      % legacy interface:
      answer = structmerge(answer, answer.info);
  end

  if isa(f, 'function_handle')
    switch nargin(f)
    case 1
      img = f(answer.(map));
    case 2
      img = f(answer.(map), answer);
    end
    tit = func2str(f);
  else
    img = f;
    tit = '';
    %if ~isequal(size(img), answer.info.size),  img = reshape(img, answer.info.size);  end
  end
  
  figure
  h=imagesc(answer.info.x_domain, answer.info.y_domain, img);
  if any(any(isnan(img))),  set(h, 'AlphaData',~isnan(img));  end  % avoid opengl software if possible.
  set(gca, 'YDir','normal')
  ch = colorbar;
  if ~isempty(units),  title(ch, sprintf('(%s)', units));  end
  axis image
  title(tit, 'Interpreter','none')
  grid on
  xlabel('East (m)')
  ylabel('North (m)')
%   set(gca, 'XTick',linspace(answer.info.x_domain(1),answer.info.x_domain(end),10+1))
%   set(gca, 'YTick',linspace(answer.(map).y_domain(1),answer.(map).y_domain(end),10+1))
  %colormap(feval(cmap))
  colormap(eval(cmap))
  
  if zero_centered
      %colormap_bwr_it(img)
      %if (prc ~= 100),  set(gca, 'CLim',[-1,+1]*prctile(abs(img(:)),prc));  end
      cl = [];  type = 'tight';
      if (prc ~= 100)
          cl = [-1,+1]*prctile(abs(img(:)),prc);
          type = 'symm';
      end
      colorlim(img, 1, gca(), ch, cl, type);
  else
      if (prc ~= 100),  set(gca, 'CLim',prctile(abs(img(:)),[0,prc]));  end
      %prc2 = (100-prc)/2;
      %set(gca, 'CLim',prctile(abs(img(:)),[prc2,100-prc2]))
  end
  %[ch, cl2] = colormbl (feval(cmap), [], img, factor, type, prc);

  if is_phase
      set(gca, 'CLim',[-180,+180])
      ylim(ch, [-180,+180])
      set(ch, 'YTick',-180:45:+180)
  end
  
  if overlay_lines
    hold on
    %for i=[3/8,1/2,1,1+1/2,2]
    for i=[1/2,1,2]
      fz = get_fresnel_zone (answer.height_ant, answer.elev, answer.azim, answer.wavelength, i);
      plot(fz.x, fz.y, 'w-', 'LineWidth',3)
      plot(fz.x, fz.y, 'k-', 'LineWidth',2)
    end
    pos_refl = get_specular_reflection (answer.height_ant, answer.elev, answer.azim);
    plot(pos_refl(2), pos_refl(1), 'w+', 'MarkerSize',12, 'LineWidth',4)
    plot(pos_refl(2), pos_refl(1), 'k+', 'MarkerSize',8, 'LineWidth',2)
    plot(0, 0, 'wo', 'MarkerSize',7, 'MarkerFaceColor','w')
  end
  if (nargout < 1),  clear h;  end
  if isfield(answer.info, 'x_lim0') ...
  && isfield(answer.info, 'y_lim0')
    xlim(answer.info.x_lim0)
    ylim(answer.info.y_lim0)
    if ~is_phase && ~zero_centered
      img2 = imcrop(answer.info.x_lim, answer.info.y_lim, img, ...
          [answer.info.x_lim0(1) answer.info.y_lim0(1) diff(answer.info.x_lim0) diff(answer.info.y_lim0)]);
      if (prc == 100)
        temp = [min(img2(:)), max(img2(:))];
      else
        temp = [prctile(img2(:), (100-prc)/2), prctile(img2(:),100-(100-prc)/2)];
      end
      if (diff(temp) ~= 0),  set(gca, 'CLim',temp);  end
    end
  end
  maximize()
end

