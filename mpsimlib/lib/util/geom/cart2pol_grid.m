function [elev_grid, azim_grid, x_grid, y_grid] = cart2pol_grid (elev_lim, step, lim, elev_scale_type)
    if (nargin < 1) || isempty(elev_lim),  elev_lim = [0, 90];  end
    if (nargin < 2) || isempty(step),  step = 0.01;  end
    if (nargin < 3) || isempty(lim),  lim  = 1;  end
    if (nargin < 4) || isempty(elev_scale_type),  elev_scale_type = 'sin';  end

    x_step = step;
    y_step = step;
    x_lim = [-1,+1] * abs(lim);
    y_lim = [-1,+1] * abs(lim);
    x_domain = x_lim(1):x_step:x_lim(2);
    y_domain = y_lim(1):y_step:y_lim(2);
    [x_grid, y_grid] = meshgrid(x_domain, y_domain);

    [temp1, temp2] = cart2pol(x_grid, y_grid);
    azim_grid = 90 - temp1*180/pi;
    azim_grid = azimuth_range_positive(azim_grid);
    switch elev_scale_type
    case 'cos'
        elev_grid1 = acosd(temp2);
        elev_grid = elev_grid1;
    case 'sin'
        elev_grid2 = asind(1-temp2);
        elev_grid = elev_grid2;
        % notice that elev_grid1 = acosd(1 - sind(elev_grid2)) = acosd(1 - temp2);
    end
    elev_grid = real(elev_grid);

    idx_bad = ~isfinite(elev_grid) | (imag(elev_grid) ~= 0);
    idx_bad = idx_bad | (elev_grid < elev_lim(1)) | (elev_grid > elev_lim(2));
    elev_grid(idx_bad) = NaN;
    azim_grid(idx_bad) = NaN;
end

%!test
%! elev_lim = [0, 45];
%! elev_lim = [];
%! [elev_grid, azim_grid, x_grid, y_grid] = cart2pol_grid (elev_lim);
%! figure, hist(elev_grid(:), 50)
%! %return
%! figure, h=imagesc(x_grid(1,:), y_grid(:,1), elev_grid); set(h, 'AlphaData',~isnan(elev_grid)), axis image, set(gca, 'YDir','normal'), colorbar
%! %return;
%! figure, h=imagesc(x_grid(1,:), y_grid(:,1), azim_grid); set(h, 'AlphaData',~isnan(azim_grid)), axis image, set(gca, 'YDir','normal'), set(gca, 'CLim',[0 360]), , colormap(hsv), h=colorbar; set(h, 'YTick',0:45:360)
%! figure, plot(x_grid(round(end/2),:), (azim_grid(round(end/2),:)), '.-k')
%! figure, plot(x_grid(round(end/2),:), (elev_grid(round(end/2),:)), '.-k')
%! figure, plot(x_grid(round(end/2),:), cosd(elev_grid(round(end/2),:)), '.-k')
