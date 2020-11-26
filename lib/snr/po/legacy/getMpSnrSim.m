function [code_error, snr_db] = getMpSnrSim (station, elev, azim, ...
step_in_wavelengths, height, height_std, freq_name, occlusion_disabled, material_bottom)
%function [code_error, snr_db] = getMpSnrSim (station, elev, azim, ...
% step_in_wavelengths, height, height_std, freq_name, occlusion_disabled) 
    material_bottom_default = 'medium dry/wet ground';
    if (nargin < 4) || isempty(step_in_wavelengths),  step_in_wavelengths = 5;  end
    if (nargin < 5) || isempty(height),  height = 2;  end
    if (nargin < 6) || isempty(height_std),  height_std = 0;  end
    if (nargin < 7) || isempty(freq_name),  freq_name = 'L1';  end
    if (nargin < 8) || isempty(occlusion_disabled),  occlusion_disabled = true;  end
    if (nargin < 9) || isempty(material_bottom),  material_bottom = material_bottom_default;  end
    if ~exist('snr_fwd_settings', 'file')
        addpath(genpath('/home/xenon/student/nievinsk/work/software/m'))
    end
    persistent dem_previous station_previous
    if strcmp(station, station_previous) && ~isempty(dem_previous)
        dem = dem_previous;
    else        
        demFile=['/data/htdocs/dem/files/mat/NED13/' station '.mat'];
        dem = getfield1(load(demFile));
        dem_previous = dem;
        station_previous = station;
    end
    %material_bottom  % DEBUG

    lim = [-250, +250, -250,+250];
    %step = 0.125;
    %step_in_wavelengths = 2;
    %ant_model = 'isotropic';    ant_radome = '';
    ant_model = 'TRM29659.00';  ant_radome = 'SCIT';

    sett = snr_fwd_settings ();
    sett.opt.ant_height_above_sfc = height;
    sett.sfc.material_bottom = material_bottom;
    sett.sfc.height_std = height_std;
    sett.ant.model = ant_model;
    sett.ant.radome = ant_radome;
    sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
    sett.sfc.type = 'interp';
    sett.sfc.grid = struct('x_domain',dem(1).x, 'y_domain',dem(1).y, 'z',dem(1).z);
    sett.sfc.PO_not_GO = true;
    sett.sat.elev = elev;
    sett.sat.azim = azim;
    sett.opt.po.lim = lim;
    sett.opt.po.step_in_wavelengths = step_in_wavelengths;
    sett.opt.freq_name = freq_name;
    sett.opt.code_name = [];
    sett.opt.spm.num_specular_max = 3;
    sett.opt.spm.fresnel_zone_keep = 1;
    sett.opt.occlusion.disabled = occlusion_disabled;
    
    setup = snr_setup (sett);

    s = warning('off', 'snr:snr_po_pre_xyz:zNaN');
    [result, snr_db, carrier_error, code_error] = snr_po (setup); %#ok<ASGLU>
    warning(s)
end

