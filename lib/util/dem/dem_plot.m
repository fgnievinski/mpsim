function dem_plot (dem, cmap, fig_ext, dem_dir, dem_suffix,overwrite_plots)
  if (nargin < 2) || isempty(cmap),  cmap = 'dkbluered';  end
  if (nargin < 3) || isempty(fig_ext),  fig_ext = 'png';  end
  if (nargin < 4),  dem_dir = [];  end
  if (nargin < 5),  dem_suffix = [];  end
  if (nargin < 6), overwrite_plots=false; end
  fig_dir1 = dem_path (dem_dir, {'fig',dem(1).code}, dem_suffix);
  n = numel(dem);
      
  for i=1:n
    if strcmp(dem(i).code, dem(1).code)
      fig_dir = fig_dir1;
    else
      fig_dir = dem_path (dem_dir, {'fig',dem(i).code}, dem_suffix);
    end
    filepath = fullfile(fig_dir, [dem(i).code '.' cmap '.'  lower(num2str(dem(i).width)) '.' fig_ext]);
    if( exist(filepath, 'file')&&~overwrite_plots),  continue;  end
      
    figure
      maximize(gcf)
      imagesc(dem(i).x, dem(i).y, dem(i).z)
      title({upper(dem(i).code),' Digital Elevation Model'})
      xlabel('East (m)')
      ylabel('North (m)')
    set(gca, 'YDir','normal')
    axis image
    grid on
    if strcmp(cmap, 'dkbluered')
      [h,cl2] = colormbl(feval(cmap, 256), 'EastOutside');
    else
      colormap(feval(cmap, 256))
      h = colorbar('Location', 'EastOutside');
    end
    %freezeColors(gca), set(h,'YLim',cl2)
    %freezeColors(h)
    title(h, 'Height')
    ylabel(h, '(m)')
    %pause
    fixfig()
    
    saveas(gcf, filepath);  
    fileattrib(filepath,'+w','g');
    
    if ~strcmp(cmap,'jet'),  continue;  end
    if(dem(i).width==500)
        dir2 = '/usr/local/adm/config/apache/htdocs/i/soil/dem/lg/';
    elseif(dem(i).width==200)
        dir2 = '/usr/local/adm/config/apache/htdocs/i/soil/dem/sm/';
    end
    try
        copyfile(filepath,fullfile(dir2,[lower(dem(i).code) '.png']),'f')
    catch err   % Catch error for trying to overwrite file owned by another user
        warning(err.identifier, err.message)
    end
  end
  % Copy jet 200 to HTDOCS

%   figure
%   for i=1:n
%     subplot(1,n,i)
%       imagesc(dem(i).x, dem(i).y, dem(i).z)
%       xlabel('East (m)')
%       %ylabel('North (m)');
%       if (i==1),  ylabel('North (m)');  end
%     set(gca, 'YDir','normal')
%     axis image
%     grid on
%     [h,cl2] = colormbl(cmap, 'EastOutside');
%     freezeColors(gca)
%     set(h,'YLim',cl2)
%     freezeColors(h)
%     %maximize(gcf)
%     %pause
%   end
%   fixfig()
%   saveas(gca, fullfile(fig_dir, [dem(1).code '.all.' fig_ext]));
  
  %return  % DEBUG
  
  i=1;
    filepath=fullfile(fig_dir1, [dem(1).code '.persp.' lower(num2str(dem(i).width)) '.' fig_ext]);
    if(exist(filepath, 'file')&&~overwrite_plots),  return;  end
    
    figure
    %figure('renderer','painters')  % DEBUG
    [xg, yg] = meshgrid(dem(i).x, dem(i).y);
      %surfl(xg, yg, dem(i).z)
      %surf(xg, yg, double(dem(i).z), ...
      %  repmat(0.35, [size(dem(i).z),3]), ...
      %  'EdgeColor','none')  % not supported by painters renderer.
      surf(xg, yg, double(dem(i).z), repmat(0.35, size(dem(i).z))),  colormap(gray(256))
      title({upper(dem(i).code),' Digital Elevation Model'})
      xlabel('East (m)')
      ylabel('North (m)')
      zlabel('Up (m)')
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

