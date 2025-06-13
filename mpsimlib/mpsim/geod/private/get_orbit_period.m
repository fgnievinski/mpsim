function T = get_orbit_period (a, GM)
    T = 2 * pi * a.^(3/2) ./ GM.^(1/2);
end
