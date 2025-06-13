function [f_grid, x_domain, y_domain] = hist2f (x, y, z, f, nx, ny, xl, yl)
    if (nargin < 4) || isempty(f),   f = @mean;  end
    if (nargin < 5) || isempty(nx),  nx = 25;  end
    if (nargin < 6) || isempty(ny),  ny = nx;  end
    if (nargin < 7) || isempty(xl),  xl = [min(x), max(x)];  end
    if (nargin < 8) || isempty(yl),  yl = [min(y), max(y)];  end
    assert(isvector(x) && isvector(y) && isvector(z))
    assert(numel(x) == numel(y) && numel(x) == numel(z))
    if ~iscell(f),  f = {f};  end
    if ischar(xl),  xl = strprctile(x, xl);  end
    if ischar(yl),  yl = strprctile(y, yl);  end
    if (nargin == (4+2))
        warning('MATLAB:hist2f:AssumingDomain', 'Assuming domain.');
        x_domain = nx;
        y_domain = ny;
    else
        %x_domain = linspace(x_lim(1), x_lim(2), nx);
        %y_domain = linspace(y_lim(1), y_lim(2), ny);
        % get mid-points:
        x_domain = linspace(xl(1), xl(2), nx+2);
        y_domain = linspace(yl(1), yl(2), ny+2);
        x_domain([1 end]) = [];
        y_domain([1 end]) = [];
    end
    x_domain_original = x_domain;
    y_domain_original = y_domain;
    %valmax = realmax();  % dangerous.
    valmax = sqrt(realmax());
    if isscalar(x_domain),  x_domain = [-valmax(), x_domain, +valmax()];  end
    if isscalar(y_domain),  y_domain = [-valmax(), y_domain, +valmax()];  end
    %if isscalar(xl),  xl = xl.*[-1,+1];  end
    %if isscalar(yl),  yl = yl.*[-1,+1];  end
    
    [x_grid, y_grid] = meshgrid(x_domain, y_domain);
    siz = size(x_grid);
    ind_grid = reshape(1:numel(x_grid), siz);
    ind = interp2nanxy(x_grid, y_grid, ind_grid, x, y, 'nearest', NaN);
    if (numel(x_domain_original) ~= numel(x_domain))
        [I,J]=ind2sub(siz,ind);
        assert(all( J==2 | isnan(J) ))
    end
    if (numel(y_domain_original) ~= numel(y_domain))
        [I,J]=ind2sub(siz,ind);
        assert(all( I==2 | isnan(I) ))
    end
    
    idx = isnan(ind);
    if any(idx)
        %warning('MATLAB:hist2f:outPts', 'Ignoring points outside grid.');
        ind(idx) = [];
          z(idx) = [];
          %clear x y
          %y(idx) = [];
          %x(idx) = [];
    end
    f2 = @(f) hist2f_aux (ind, siz, z, f, x_domain, y_domain, x_domain_original, y_domain_original);
    f_grid = cellfun2(f2, f);
    if isscalar(f),  f_grid = f_grid{1};  end
end

function f_grid = hist2f_aux (ind, siz, z, f, x_domain, y_domain, x_domain_original, y_domain_original)
    f_grid = accumarray(ind, z, [prod(siz),1], f, NaN);
    f_grid = reshape(f_grid, siz);
    if (numel(x_domain_original) ~= numel(x_domain))
        f_grid(:,[1 end]) = [];
    end
    if (numel(y_domain_original) ~= numel(y_domain))
        f_grid([1 end],:) = [];
    end
end
        
%!test
%! N = ceil(1000*rand);
%! x = rand(N, 1);
%! y = rand(N, 1);
%! z = exp(x) .* exp(y);
%! %profile on
%! [m, xd, yd] = hist2f(x, y, z);
%! m2 = hist2f(x, y, z, {@mean, @std});
%! myassert(m2{1}, m)
%! %profile viewer
%! figure
%!   hold on
%!   %plot(x, y, '+k')
%!   imagesc(xd, yd, m, 'AlphaData',~isnan(m))
%!   axis tight
%!   colorbar

