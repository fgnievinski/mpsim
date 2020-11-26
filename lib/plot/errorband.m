function [h_line, h_band] = errorband (x, y, e, ...
line_style, band_color, band_transparency, single_point_dx, edge_color)
%ERRORBAND  Filled-in error bands.
% 
%   See also: ERRORBAR

    myassert(numel(x), numel(y));
    if ~issorted(x),  [x, ind] = sort(x);  y = y(ind);  e = e(ind,:);  end
    if (nargin < 4) || isempty(line_style),  line_style = '-k';  end
    if (nargin < 5) || isempty(band_color),  band_color = 0.5;  end
    if (nargin < 6) || isempty(band_transparency),  band_transparency = 0.5;  end
    if (nargin < 7) || isempty(single_point_dx),  single_point_dx = 0.5;  end
    if (nargin < 8) || isempty(edge_color),  edge_color = 'none';  end
    if isscalar(band_color) && isnumeric(band_color),  band_color = band_color .* [1 1 1];  end
    if isscalar(edge_color) && isnumeric(edge_color),  edge_color = edge_color .* [1 1 1];  end

    [l, u] = std2lu (e, x);
  
    %idx = ( isnan(x) | isnan(y) | isnan(l) | isnan(u) );
    idx = ( ~isfinite(x) | ~isfinite(y) | ~isfinite(l) | ~isfinite(u) );
    
    if any(idx)
        h_band = errorband_nan (idx, x, y, l, u, band_color, single_point_dx);
    else
        h_band = fill (...
            [x(:); flipud(x(:))], ...
            [y(:)+u(:); flipud(y(:)-l(:))], ...
            band_color);
    end
    set(h_band, 'FaceAlpha',band_transparency)
    set(h_band, 'EdgeColor',edge_color)

    washold = ishold();
    hold on
    if ~iscell(line_style),  line_style = {line_style};  end
    h_line = plot (x, y, line_style{:});
    if ~washold,  hold('off');  end

    if (nargout < 1),  clear h_line;  end
    if (nargout < 2),  clear h_band;  end
end

%%
function h_band = errorband_nan (idx, x, y, l, u, band_color, single_point_dx)
    hold on
    ind = find(idx);
    ind = [0; ind; numel(x)+1];
    ind4 = [];
    h_band = [];
    t = nanmedian(diff(x));
    dt = [-1,+1]*t*single_point_dx;
    for i=1:numel(ind)-1
        ind1 = ind(i)+1;
        ind2 = ind(i+1)-1;
        ind3 = (ind1:ind2)';
        ind4 = [ind4; ind3]; %#ok<AGROW>
        if isempty(ind3),  continue;  end
        switch numel(ind3)
        case 0
            continue;
        case 1
            h_band = vertcat(h_band, fill (...
                [x(ind3)+dt(:); flipud(x(ind3)+dt(:))], ...
                [y(ind3)+u(ind3)*[1;1]; flipud(y(ind3)-l(ind3))*[1;1]], ...
                band_color)); %#ok<AGROW>
        otherwise
            h_band = vertcat(h_band, fill (...
                [x(ind3); flipud(x(ind3))], ...
                [y(ind3)+u(ind3); flipud(y(ind3)-l(ind3))], ...
                band_color)); %#ok<AGROW>
        end
    end
    ind4b = find(~idx);
    assert(isequal(ind4, ind4b))
end
