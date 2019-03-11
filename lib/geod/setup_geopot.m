function geopot = setup_geopot (dir, preload)
%SETUP_GEOPOT: Setup geopotential coefficients.

    if (nargin < 2) || isempty(preload),  preload = false;  end
    
    filename_raw = 'egm96_to360.ascii';
    filepath_raw = fullfile(dir, filename_raw);
    filepath_pre = [filepath_raw '.mat'];
    
    if ~preload && exist(filepath_pre, 'file')
        geopot = load(filepath_pre, '-mat');
        return;
    end

    temp = load(filepath_raw);
    [n, m, C, S] = deal2(temp);
    geopot = struct();
    geopot.C = sparse (n+1, m+1, C, 360+1, 360+1);
    geopot.S = sparse (n+1, m+1, S, 360+1, 360+1);
    if preload,  save(filepath_pre, '-struct', 'geopot');  end
    
    % +1 because n and m are indexed based on zero,
    % but matlab's indices are based on one.
    
    % Spherical harmonic expansion coefficients:
    % Available at:
    % at <ftp://cddis.gsfc.nasa.gov/pub/egm96/general_info/egm96_to360.ascii>
    %
    % Its contents are described in its readme file, available at 
    % <ftp://cddis.gsfc.nasa.gov/pub/egm96/general_info/readme.egm96>
    % which says:
    % (n,m,Cnm,Snm,sigmaCnm,sigmaSnm) --> FORMAT(2I4,2E20.12,2E16.8) 
    % "All values refer to unitless fully-normalized coefficients."
end
