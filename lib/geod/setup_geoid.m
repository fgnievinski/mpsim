function geoid = setup_geoid (dir, preload)
%SETUP_GEOID: Setup geoid map.

    if (nargin < 2) || isempty(preload),  preload = false;  end
    
    filename_raw = 'WW15MGH.GRD';
    filepath_raw = fullfile(dir, filename_raw);
    filepath_pre = [filepath_raw '.MAT'];
    
    if ~preload && exist(filepath_pre, 'file')
        geoid = load(filepath_pre, '-mat');
        return;
    end
    
    p = path();
    path(p, dir);  % "The gridded EGM96 data set must be on your path"
    [data, ref] = egm96geoid(1);
    path(p);
    info.ref = ref;

    info.lat_domain = -90:0.25:+90;
    info.lon_domain =   0:0.25:360;
    %[info.lon, info.lat] = meshgrid(info.lon_domain, info.lat_domain);

    geoid = struct();
    geoid.data = data;
    geoid.info = info;
    
    if preload,  save(filepath_pre, '-struct', 'geoid');  end
end
