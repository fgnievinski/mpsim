function hs = dem_plot3 (code, x, y, z, label, units, clim, ctick, cmap, dem_dir, dem_suffix, fig_ext, width,overwrite_plots)
  if (nargin < 7),  clim = [];  end
  if (nargin < 8),  ctick = [];  end
  if (nargin < 9) || isempty(cmap),  cmap = 'jet';  end
  if (nargin < 10),  dem_dir = [];  end
  if (nargin < 11),  dem_suffix = [];  end
  if (nargin < 12) || isempty(fig_ext),  fig_ext = 'png';  end
  if (nargin < 13) || isempty(width),  width = [];  end
  if (nargin <14) || isempty(overwrite_plots),overwrite_plots=false; end
  fig_dir = dem_path (dem_dir, {'fig',code}, dem_suffix);
  filepath = fullfile(fig_dir, [code '.' strrep(lower(label), ' ', '_') '.' lower(num2str(width)) '.' fig_ext]);
  if(exist(filepath, 'file')&&~overwrite_plots),  if (nargout > 0),  hs = nan(0,3);  end;  return;  end

  figure
    maximize(gcf)
    imagesc(x, y, z, 'AlphaData',~isnan(z))
    title({upper(code),' Digital Elevation Model'})
    xlabel('East (m)')
    ylabel('North (m)')
  set(gca, 'YDir','normal')
  axis image
  grid on

    if strcmp(cmap, 'dkbluered')
      [h,cl2] = colormbl(feval(cmap, 256), 'EastOutside');
    else
      colormap(feval(cmap, 256))
      if ~isempty(clim),  set(gca, 'CLim',clim);  end
      if ischar(cmap),  cmap = eval(cmap);  end
      colormap(cmap)
      h = colorbar('location', 'EastOutside');
      if ~isempty(ctick),  set(h, 'YTick',ctick);  end
    end
  
  %title(h, sprintf('%s\n(%s)', label, units))
  title(h, label)
  ylabel(h, sprintf('(%s)', units))
  
  if isunix(),  set(gcf(), 'renderer','painters');  end  % otherwise MATLAB crashes -- endless video driver issues.
  fixfig()
  
  saveas(gcf(), filepath);
  fileattrib(filepath,'+w','g');
  if (nargout < 1),  return;  end
  hs = struct('figure',gcf(), 'axis',gca(), 'image',gco(), 'colorbar',h);  
end
