function [m, xl, yl, A] = hist2(x, y, nx, ny, xl, yl, get_sparse)
    if (nargin < 3) || isempty(nx),  nx = 25;  end
    if (nargin < 4) || isempty(ny),  ny = nx;  end
    if (nargin < 5) || isempty(xl),  xl = [min(x), max(x)];  end
    if (nargin < 6) || isempty(yl),  yl = [min(y), max(y)];  end
    if (nargin < 7) || isempty(get_sparse),  get_sparse = false;  end
    myassert(isvector(x))
    myassert(isvector(y))
    myassert(isscalar(nx))
    myassert(isscalar(ny))
    if ischar(xl),  xl = strprctile(x, xl);  end
    if ischar(yl),  yl = strprctile(y, yl);  end
    if isscalar(xl),  xl = xl.*[-1,+1];  end
    if isscalar(yl),  yl = yl.*[-1,+1];  end
    xr = xl(2) - xl(1);
    yr = yl(2) - yl(1);
    xs = xr/(nx+1);
    ys = yr/(ny+1);
    A = xs*ys;
    idx = (xl(1) < x & x < xl(2)) ...
        & (yl(1) < y & y < yl(2));
    x(~idx) = [];
    y(~idx) = [];
    x = round((nx-1).*(x - xl(1))./xr)+1;
    y = round((ny-1).*(y - yl(1))./yr)+1;
    m = sparse(y,x,ones(length(x),1));
    %m = sparse(x,y,ones(length(x),1));  % WRONG!
    if get_sparse,  return;  end
    m = full(m);
end
% Date: 2005-12-29
% From: Iain Strachan (igd.strachan@gmail.com)
% Rating:
% Comments: If the histogram spacing is regular and assumed to be divided between the minimum and maximum values, then one can use the useful property of the sparse(i,j,vals) command, that it sums the values assigned to repeated indices, to do a 2d histogram very quickly, something like this...
% <http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1487&objectType=file>

%!#test
%! N = 1000 + ceil(1000*rand);
%! x = randn(N, 1);
%! y = randn(N, 1);
%! %profile on
%! [m, xd, yd] = hist2(x, y);
%! %profile viewer
%! figure
%!   hold on
%!   %imagesc(xd, yd, m, 'AlphaData',0.5)
%!   imagesc(xd, yd, m)
%!   plot(x, y, '+w')
%!   axis image
%!   colorbar
%!   maximize()
%! close(gcf)

%!test
%! % points outside area:
%! N = 1000 + ceil(1000*rand);
%! x = randn(N, 1);
%! y = randn(N, 1);
%! [m, xd, yd] = hist2(x, y, [], [], 0.5, 0.5);
%! %profile viewer
%! figure
%!   hold on
%!   %imagesc(xd, yd, m, 'AlphaData',0.5)
%!   imagesc(xd, yd, m)
%!   plot(x, y, '+w')
%!   axis image
%!   xlim(xd([1,end]))
%!   ylim(yd([1,end]))
%!   colorbar
%!   maximize()


