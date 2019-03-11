function [data2, data3] = pol2cart_degrid (xdir_grid, ydir_grid, data_grid, elev_lim, azim_step, factor, label)
  myassert(size(data_grid), size(xdir_grid))
  
  %elev_domain_cart = get_elev_regular_in_sine (100, elev_lim(1), elev_lim(2), false, true, 'ascend');
  %elev_domain_cart = get_elev_regular_in_sine (100, elev_lim(1), elev_lim(2), false, false, 'ascend');
  %elev_domain_cart = (0:1/2:90)';
  elev_domain_cart = linspace(elev_lim(1), elev_lim(2))';
    %figure, plot(elev_domain_cart, '.-k')
  azim_domain_cart = (0:azim_step:360)';
  %azim_domain_cart = (0:45:360)';
  azim_domain_cart(end) = [];
  
  [elev_grid_cart, azim_grid_cart] = meshgrid(elev_domain_cart, azim_domain_cart);
  togrid_cart = @(in) reshape(in, size(elev_grid_cart));
  elev_grid_cart2 = elev_grid_cart;  % EXPERIMENTAL
  %elev_grid_cart2 = asind(1 - cosd(elev_grid_cart));  % EXPERIMENTAL
  temp = sph2cart_local([elev_grid_cart2(:), azim_grid_cart(:)]);
  temp = neu2xyz(temp);
    %max(abs(imag(temp)))  % DEBUG
  xdir_grid_cart = togrid_cart(temp(:,1));
  ydir_grid_cart = togrid_cart(temp(:,2));
  %   figure
  %   hold on
  %   axis equal
  %   plot(xdir_grid(:), ydir_grid(:), '.b'), axis equal
  %   plot(xdir_grid_cart(:), ydir_grid_cart(:), '.k'), axis equal
  %   interp2(xdir_grid, ydir_grid, togrid(data0(:)), [0; 0.5], [0; 0.5])
    %figure, imagesc(isnan(togrid(data0(:)))), colorbar
  
  % temp = interp2(xdir_grid, ydir_grid, data, linspace(0, 1), linspace(0, 0));
  %   figure, plot(linspace(0, 1), temp)
  pol2cart_interp = @(in) togrid_cart(interp2(xdir_grid, ydir_grid, in, xdir_grid_cart(:), ydir_grid_cart(:), 'cubic'));
  
  data2 = pol2cart_interp(data_grid);
    %figure, plot(elev_domain_cart, data2, '.-k')
    %figure, plot(elev_domain_cart, data2, '.-k')
    %figure, imagesc(elev_domain_cart, azim_domain_cart, data2), set(gca, 'YDir','normal')
    figure
      imagesc(azim_domain_cart, elev_domain_cart, transpose(data2)), set(gca, 'YDir','normal')
      xlabel('Azimuth (degrees)')
      xlabel('Elevation angle (degrees)')
      

  data3 = nanrmse(data2, 2);
    figure, plot(azim_domain_cart, data3, '.-k')
    grid on
    xlabel('Azimuth (degrees)')
    ylabel(label)
    xlim([0,360])
    set(gca, 'XTick',0:45:360)

  data4 = nanrmse(data3, 1);
  
  temp = repmat((0:1:(numel(azim_domain_cart)-1))'*data4*factor, [1,numel(elev_domain_cart)]);
  temp2 = data2 + temp;
  figure, plot(elev_domain_cart, temp2, '-k', 'LineWidth',2), grid on, xlabel('Elevation angle (degrees)'), ylabel(label)
    hold on, text(repmat(elev_domain_cart(1), [numel(azim_domain_cart),1]), temp(:,1), num2str(azim_domain_cart(:)))
    text(elev_domain_cart(1), temp(end,1)+1.5*data4*factor, 'Azim.', 'FontWeight','bold')
    ylim([min(temp2(:)), max(temp2(:))])
    
end

