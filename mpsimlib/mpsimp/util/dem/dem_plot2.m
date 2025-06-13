function dem_plot2 (dem, fig_ext, dem_dir, dem_suffix,overwrite_plots)
  if (nargin < 2) || isempty(fig_ext),  fig_ext = 'png';  end
  if (nargin < 3),  dem_dir = [];  end
  if (nargin < 4),  dem_suffix = [];  end
  if (nargin < 5), overwrite_plots=false; end
  fig_dir1 = dem_path (dem_dir, {'fig',dem(1).code}, dem_suffix);
  n = numel(dem);
      
  for i=1:n
    if strcmp(dem(i).code, dem(1).code)
      fig_dir = fig_dir1;
    else
      fig_dir = dem_path (dem_dir, {'fig',dem(i).code}, dem_suffix);
    end
    filepath = fullfile(fig_dir, [dem(i).code '.persp.' lower(num2str(dem(i).width)) '.' fig_ext]);
    if( exist(filepath, 'file')&&~overwrite_plots),  continue;  end
    figure
    %figure('renderer','painters')  % DEBUG
    [xg, yg] = meshgrid(dem(i).x, dem(i).y);
      %TODO: use mysurf.m
      %surfl(xg, yg, dem(i).z)
      %surf(xg, yg, double(dem(i).z), ...
      %  repmat(0.35, [size(dem(i).z),3]), ...
      %  'EdgeColor','none')  % not supported by painters renderer.
      surf(xg, yg, double(dem(i).z), repmat(0.35, size(dem(i).z))),  colormap(gray(256))
      title({upper(dem(i).code),' Digital Elevation Model'})
      xlabel('East (m)')
      ylabel('North (m)')
      zlabel('Height (m)')
    set(gca, 'YDir','normal')
    shading interp    
    lighting phong
    material dull
    camlight('headlight')
    %camlight('right')
    %camlight('left')
    lightangle(0, 90)
    %colorbar
    axis vis3d
    set(gca, 'DataAspectRatio',1./[1,1,3])  
    grid on
    fixfig()
    saveas(gcf, filepath);
    fileattrib(filepath,'+w','g');
  end
end

