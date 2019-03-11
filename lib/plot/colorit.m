function colorit (x)
set(gca, 'CLim',[-max(abs(x)), +max(abs(x))])
colormap(colormap_bwr), colorbar
h=colorbar; set(h, 'YLim', [min(x), max(x)])
end

