function [img2, x_domain2, y_domain2, x_lim2, y_lim2, rect2] = imcrop2 (half_dim2, img1, x_domain1, y_domain1)
    width2  = 2 * half_dim2;
    height2 = 2 * half_dim2;
    x_lim2 = [-1,+1] * half_dim2;
    y_lim2 = [-1,+1] * half_dim2;
    x_lim1 = x_domain1([1 end]);
    y_lim1 = y_domain1([1 end]);
    
    flippedlr = (sign(diff(x_lim1)) < 0);
    flippedup = (sign(diff(y_lim1)) < 0);
    if flippedlr
      x_lim1 = fliplr(x_lim1);
      img1 = fliplr(img1);
    end
    if flippedup
      %y_lim1 = flipud(y_lim1);  % WRONG!
      y_lim1 = flipud(y_lim1')';
      img1 = flipud(img1);
    end
    
    %rect2 = [min(x_lim2), min(y_lim2), width2, height2];
    rect2 = [x_lim2(1), y_lim2(1), width2, height2];
    [x_lim1b, y_lim1b, img2, rect2b] = imcrop (x_lim1, y_lim1, img1, rect2); %#ok<ASGLU>
      myassert(rect2b, rect2)

    clear img1  % prevent misuse
    if flippedlr
      x_lim2 = fliplr(x_lim2);
      img2 = fliplr(img2);
      %img1 = fliplr(img1);
    end
    if flippedup
      %y_lim2 = flipud(y_lim2);  % WRONG!
      y_lim2 = flipud(y_lim2')';
      img2 = flipud(img2);
      %img1 = flipud(img1);
    end
    
    x_domain2 = linspace(x_lim2(1), x_lim2(2), size(img2,2));
    y_domain2 = linspace(y_lim2(1), y_lim2(2), size(img2,1)); 
end

%!test
%! img1 = membrane(1,25);
%! for i=1:2
%!   radius = 50;
%!   x_lim0 = [-100, +100];  x0 = -50;
%!   switch i
%!   case 1,  y_lim0 = [-100, +100];  y0 = +50;
%!   case 2,  y_lim0 = [+100, -100];  y0 = -50;
%!   end
%!   x_lim1 = x_lim0 - x0;
%!   y_lim1 = y_lim0 - y0;
%!   [img2, ~, ~, x_lim2, y_lim2, rect] = imcrop2 (radius, img1, x_lim1, y_lim1);
%!   figure
%!   h1=subplot(1,2,1);
%!     imagesc(x_lim1, y_lim1, img1)
%!     imrect(h1, rect);
%!     axis image
%!     set(h1, 'YDir','normal')
%!   h2=subplot(1,2,2);
%!     imagesc(x_lim2, y_lim2, img2)
%!     axis image
%!     set(h2, 'CLim',get(h1, 'CLim'))
%!     set(h2, 'YDir','normal')
%! end
