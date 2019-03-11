function antenna_gain_plot6 (data)

[x_grid, y_grid, z_grid] = sph2cart(...
    data.densemap.azim_grid*pi/180, ...
    data.densemap.elev_grid*pi/180, ...
    data.densemap.final_grid);
  
r = max(data.densemap.final_grid(:));
r = r * 1.15;

figure
  axis equal
  hold on

  arrow3([0 0 0], [r 0 0], '-b2.0', 0.5)
  arrow3([0 0 0], [0 r 0], '-g2.0', 0.5)
  arrow3([0 0 0], [0 0 r], '-r2.0', 0.5)
  mysurf(x_grid, y_grid, z_grid, 0.5, 3)

  set(gca(), 'Color','none')
  set(gca(), 'XTick',[], 'YTick',[], 'ZTick',[])
  set(gca(), 'XColor','w', 'YColor','w', 'ZColor','w')
  
  view(-45+180, 15)
  
  title(data.filename, 'Interpreter','none')
end

