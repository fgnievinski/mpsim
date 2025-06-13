function [img, x, y] = imcropnanborder (img, x, y)
  siz = size(img);
  if (nargin < 2) || isempty(x),  x = (1:siz(2));  end
  if (nargin < 3) || isempty(y),  y = (1:siz(1));  end
  while true
    ind = get_border_ind (img);
    if ~any(isnan(img(ind))),  break;  end
    img(ind) = [];
    siz = siz - 2;
    img = reshape(img, siz);
    x = x(2:end-1);
    y = y(2:end-1);
  end
end

%!test
%! img = rand(4,5);
%! img(1,1) = NaN;
%! img2 = img(2:end-1, 2:end-1);
%! img2b = imcropnanborder(img);
%! myassert(img2b, img2)

