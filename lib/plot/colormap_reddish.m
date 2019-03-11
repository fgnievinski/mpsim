function c = colormap_reddish (m)
    if (nargin < 1),  m = size(get(gcf,'colormap'),1);  end

    r = linspace(0, 1, m)';
    c = [r zeros(m, 2)];
end

