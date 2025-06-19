function azim = azimuth_stat (azim, f, varargin)
    azim_original = azim;
    [x, y] = azimuth_auxi (azim);
    x = f(x, varargin{:});
    y = f(y, varargin{:});
    azim = azimuth_aux (x, y);
    if all(azim_original >= 0),  azim = azimuth_range_positive(azim);  end
end
