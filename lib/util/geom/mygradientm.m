function [aspect,slope,grade,rgb,dz_dx,dz_dy] = mygradientm (img, PixelScale)
    if (nargin < 2),  PixelScale = [1,1];  end
    if (numel(img) == 2)
        dz_dx = img(1);
        dz_dy = img(2);
    else
        [dz_dx, dz_dy] = gradient(img, PixelScale(1), PixelScale(2));
    end
    [slope, aspect] = horizgrad2slopeaspect(dz_dx, dz_dy);
    if (nargout < 3),  return;  end
    grade = 100 * tand(slope);
    if (nargout < 4),  return;  end
    hsv = cat(3, ...
        aspect ./ 360, ...
        grade ./ max(max(grade)), ...
        ones(size(img)) ...
    );
    rgb = hsv2rgb(hsv);
end

%!test
%! img = peaks(100);
%! [aspect,slope,grade,rgb,dz_dx,dz_dy] = mygradientm(img);
%! figure, hold on, surf(img, 'EdgeColor','none'), set(gca, 'YDir','normal'), title('img'), colorbar, view(3), axis vis3d
%! figure, imagesc(slope), set(gca, 'YDir','normal'), colormap(jet), title('slope'), colorbar
%! figure, imagesc(grade), set(gca, 'YDir','normal'), colormap(jet), title('grade'), colorbar
%! figure, imagesc(aspect), set(gca, 'CLim',[0,360], 'YDir','normal'), colormap(hsv), title('aspect'), colorbar('YLim',[0,360], 'YTick',0:90:360)
%! figure, image(rgb), set(gca, 'YDir','normal'), title('rgb')
%! return
%! % Each figure -- not axes! -- has its own colormap property.
%! % You can use subimage in conjunction with subplot to create figures with multiple images, even if the images have different colormaps. subimage works by converting images to truecolor for display purposes, thus avoiding colormap conflicts.
%! figure
%! subplot(2,2,1), surf(img, 'EdgeColor','none'), set(gca, 'YDir','normal'), title('img'), colorbar, view(3)
%! subplot(2,2,2), subimage(aspect, hsv), set(gca, 'YDir','normal'), title('aspect'), colorbar
%! subplot(2,2,3), subimage(slope, jet), set(gca, 'YDir','normal'), title('slope'), colorbar
%! subplot(2,2,4), image(rgb), set(gca, 'YDir','normal'), title('rgb'), colorbar

