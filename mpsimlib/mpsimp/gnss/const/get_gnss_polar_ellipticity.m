function [alpha_db, alpha, beta, beta_sq] = get_gnss_polar_ellipticity (...
gnss_name, freq_name, block_name)
    switch upper(gnss_name)
    case 'GPS',  fnc = @get_gps_polar_ellipticity;  argin = {freq_name, block_name};
    case 'GLO',  fnc = @get_glo_polar_ellipticity;  argin = {freq_name};
    end
    [alpha_db, alpha, beta, beta_sq] = fnc(argin{:});
end

