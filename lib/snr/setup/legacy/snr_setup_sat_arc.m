function sat = snr_setup_sat_arc (arc, i, j, k, l, f)
    if (nargin < 6) || isempty(f),  f = 'smooth';  end
    %f  % DEBUG
    epoch = arc{i}{j}{k}{l}.(f).epoch;
    azim  = arc{i}{j}{k}{l}.(f).azim;
    elev  = arc{i}{j}{k}{l}.(f).elev;
    obs   = arc{i}{j}{k}{l}.(f).obs;
    [sat, idx, ind] = snr_setup_sat_simple (epoch, azim, elev);
    sat.obs = obs(idx);
    %sat.obs = sat.obs(ind);  % WRONG!!!
    sat.obs_sorted = sat.obs(ind);
end

