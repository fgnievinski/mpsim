function [ant_eff_len_rhcp, ant_eff_len_lhcp] = snr_fwd_antenna (...
dir_name, geom, setup)
    switch lower(dir_name)
    case {'direct','satellite'}
        dir = geom.direct.dir.ant;
    case {'reflected','reflection','surface'}
        dir = geom.reflection.dir.ant;
    otherwise
        error('snr:badDirName', ...
            'dir_name should be either "direct" or "reflected".')
    end
    %[ant_pattern_rhcp, ant_pattern_lhcp, ...
    % ant_ampl_rhcp, ant_ampl_lhcp] = ...
    %    get_antenna_pattern (dir.elev, dir.azim, setup.ant); %#ok<NASGU>
    [ant_pattern_rhcp, ant_pattern_lhcp] = ...
        get_antenna_pattern (dir.elev, dir.azim, setup.ant);

    % The final ant_eff_len_rhcp and ant_eff_len_lhcp are the same in both 
    % formulations, but the isotropic formulation ("iso") is faster.
    formulation = 'iso';
    %formulation = 'noniso';  % DEBUG
    ant_eff_len_norm_iso = setup.ant.eff_len_norm_iso;
    switch formulation
    case 'iso'
        ant_eff_len_rhcp = ant_eff_len_norm_iso .* ant_pattern_rhcp;
        ant_eff_len_lhcp = ant_eff_len_norm_iso .* ant_pattern_lhcp;
    otherwise
        ant_power_total = ant_pattern_rhcp.^2 + ant_pattern_lhcp.^2;
        ant_power_total_sqrt = sqrt(ant_power_total);
        ant_eff_len_norm = ant_eff_len_norm_iso * ant_power_total_sqrt;  % scalar
        ant_eff_len_dir_rhcp = ant_pattern_rhcp ./ ant_power_total_sqrt;
        ant_eff_len_dir_lhcp = ant_pattern_lhcp ./ ant_power_total_sqrt;
          temp = ant_eff_len_dir_rhcp.^2 + ant_eff_len_dir_lhcp.^2;
          %temp = max(abs(temp - 1))
          assert(temp < sqrt(eps()))
        ant_eff_len_rhcp = ant_eff_len_norm .* ant_eff_len_dir_rhcp;
        ant_eff_len_lhcp = ant_eff_len_norm .* ant_eff_len_dir_lhcp;
    end
end

