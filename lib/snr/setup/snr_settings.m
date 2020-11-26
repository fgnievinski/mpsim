function sett = snr_settings ()
%SNR_SETTINGS: Return default settings for GNSS multipath simulator
% 
% SYNTAX:
%    sett = snr_settings ();
%
% INPUT: none    
%
% OUTPUT:
%    sett: [structure] default settings
%
% EXAMPLE:
%    sett = snr_settings ();
%    sett.ref.height_ant = 5.0;
%    setup = snr_setup (sett)
%    result = snr_fwd (setup);
%
% REMARKS:
% - Output "sett" contains the following nested sub-structures:
%    .sat:  [structure] satellite observation conditions
%    .ref:  [structure] reference system
%    .opt:  [structure] general options
%    .ant:  [structure] antenna electromagnetic response
%    .sfc:  [structure] reflecting surface/medium
%    .bias: [structure] biases
% - Each sub-structure contains the following fields:
% 
%    .sat: [structure] Satellite Observation Conditions
%     if you wish to define specific satellite directions, set the following fields:
%      .elev: [vector] satellite elevation angle (in degrees)
%      .azim: [vector] satellite azimuth (in degrees)
%      .epoch: [vector] satellite observation epoch (in seconds)
%     if you wish to have the simulation generate uniformly spaced directions, set the following fields instead:
%      .num_obs: [scalar] Number of observations (count)
%      .elev_lim: [vector] satellite elevation angle limits; min, max (in degrees)
%      .azim_lim: [vector] satellite azimuth limits; min, max (in degrees, clockwise from north)
%      .epoch_lim: [vector] satellite observation epoch limits; min, max (in seconds)
%      .regular_in_sine: [scalar] Generate directions regularly spaced in sine of elevation angle? False means regularly spaced in elevation angle itself. (logical/Boolean)
% 
%    .ref: [structure] Reference System
%      .height_ant: [scalar] Height of the antenna (in meters)
%      .height_off: [scalar, vector] Height offset (in meters); if non-scalar, it should have as many elements as satellite observations exist (as set by either the value of sett.sat.num_obs or the size of sett.sat.elev).
%      .velocity: [scalar] Vertical velocity (in meters per second); used to populate empty height_off
%      .dist_arp_pivot: [scalar] Distance between ARP and pole/monument pivot point (in meters)
%      .ignore_vec_apc_arp: [scalar] Ignore offset vector between antenna phase center (APC) and reference point (ARP)? (logical/Boolean)
% 
%    .opt: [structure] General Options
%      .gnss_name: [char] Global Navigation Satellite System name ('GPS'; 'GLO' or 'GLONASS')
%      .freq_name: [char] Carrier frequency name ('L1', 'L2', 'L5' for GPS; 'R1', 'R2' for GLONASS)
%      .channel: [scalar] Frequency channel number (-7,...,+13; applies only to GLONASS)
%      .code_name: [char] Modulation code name ('C/A', 'P(Y)', 'L2C', '' for GPS; 'C/A', 'P' for GLONASS)
%      .subcode_name: [char] Sub-code name ('CM', 'CL' for code_name = 'L2C'; 'I', 'Q' for freq_name = 'L5')
%      .block_name: [char] Satellite block ('II', 'IIA', 'IIR', 'IIR-M', 'IIF')
%      .incid_polar_power: [scalar] Incident polarimetric power, LHCP over RHCP (in watts-per-meter-squared over watts-per-meter-squared; real-valued)
%      .incid_polar_phase: [scalar] Incident polarimetric phase, LHCP minus RHCP (in degrees)
%      .special_fringes: [char] Force special type of fringes? ('common','disabled','superior','inferior'); 'common' means ordinary simulation; 'disabled' means simulate only the trend.
%      .disable_incident_power_trend: [scalar] Assume elevation angle independent incident power? (logical/Boolean)
%      .disable_tracking_loss: [scalar] Disable P(Y) tracking losses? (logical/Boolean); see snr_fwd_tracking_loss.m for details.
%      .extrap_tracking_loss: [scalar] Extrapolate P(Y) tracking-loss empirical data? (logical/Boolean)
%      .phase_approx_small_power: [scalar] Calculate phase error assuming small interf. power? (logical/Boolean)
%      .max_plot: [scalar] Maximize plot figure window? (logical/Boolean)
%      .num_specular_max: [scalar] maximum number of simultaneous specular reflections requested by the user; not all surface models support it (>=1)
%      .rec: [structure] Receiver options:
%        .rec.temperature_noise: [scalar] Receiver noise temperature (in kelvin)
%        .rec.bandwidth_noise: [scalar] Noise bandwidth (in hertz)
%        .rec.ant_density_noise_db: [scalar] Antenna noise temperature (in decibel of watts per hertz, or dB-W/Hz)
%      .dsss: [structure] Code modulation options, as used for direct-sequence spread-spectrum (DSSS) modulation (currently only binary phase shift keying (BPSK), for both GPS CDMA and GLONASS FDMA).
%        .disable: [scalar] Disable code modulation? (logical/Boolean)
%        .assume_zero: [scalar] Assume zero delay error? (logical/Boolean)
%        .approx_small_delay: [scalar] Calculate code error assuming small interf. delay? (logical/Boolean)
%        .approx_small_power: [scalar] Calculate code error assuming small interf. power? (logical/Boolean)
%        .iterate: [scalar] Iterate in the discriminator corrections? (logical/Boolean)
%        .delay_tol: [scalar] Convergence tolerance (in meters)
%        .correlator_spacing_in_chips: [scalar] Correlator spacing; it is twice the early-prompt or late-prompt separation (in multiples of chip)
%        .discriminator_type: [char] Type of code discriminator function ('non-coherent early minus late envelope', 'non-coherent early minus late power', 'quasi-coherent dot product power', 'coherent dot product')
%        .neglect_doppler: [scalar] Neglect Doppler effect on Woodward ambiguity function? (logical/Boolean)
%        .coherent_integration_time: [scalar] Coherent integration time; used in Doppler effect (in seconds)
% 
%    .ant: [structure] Antenna Electromagnetic Response
%      .slope: [scalar] Boresight zenith angle; zero means boresight/zenith are alignmed (in degrees)
%      .slope: [char] Boresight zenith angle ('upright', 'tipped' or 'sideways', and 'upside-down' are equivalent to slope of zero, 90, and 180 degrees, respectively)
%      .aspect: [scalar] Boresight azimuth; zero means antenna reference direction is aligned with north (in degrees)
%      .aspect: [char] Boresight azimuth ('north', 'south', 'east', 'west' are equivalent to aspect of zero, 90, 180, and 270 degrees, respectively)
%      .axial: [scalar] Axial rotation (in degrees); concides with aspect angle only when slope is 'upright' or zero
%      .model: [char] IGS designation (e.g., 'TRM29659.00', 'LEIAR25', etc); can also be 'isotropic', optionally with a polarization ('rhcp', 'lhcp', 'vertical', 'horizontal') concatenated (e.g., 'isotropic rhcp').
%      .radome: [char] IGS designation (e.g., 'NONE', 'SCIT', etc).
%      .sph_harm_degree: [scalar] Maximum spherical harmonics degree and order, when fitting antenna profile data (unitless)
%      .switch_left_right: [scalar] Swap RHCP and LHCP patterns, artificially? (logical/Boolean)
%      .load_redundant: [scalar] Load additional antenna data in case you wish to plot the gain pattern (logical/Boolean)
%      .load_extended: [scalar] Load extended format profile data (see m/snr/data/ant/readme.txt), if available? Only effective if load_redundant is true or there is no pre-loaded disk-saved antenna data. (logical/Boolean)
%      .rhcp_phase: [scalar] Antenna RHCP phase; a uniform value, useful in the absence of detailed phase pattern (in degrees)
%      .polar_phase: [scalar] Antenna polarimetric phase, LHCP minus RHCP; a uniform or direction-independent value (in degrees)
% 
%    .sfc: [structure] Reflecting Surface/Medium
%      .material_top: [char, structure] Top half-space material (check get_permittivity for options)
%      .material_bottom: [char, structure] Bottom half-space material (check get_permittivity for options)
%      .height_std: [scalar] Effective surface roughness, or standard deviation of the small-scale residual height above and below a large-scale trend surface (in meters)
%      .fnc_snr_setup_sfc_geometry: [function handle] Function responsible for setting up the surface geometry (@snr_setup_sfc_geometry_{horiz, tilted, dem})
%     if .fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted:
%      .slope: [scalar] Surface rise; 0-90 (in degrees)
%      .aspect: [scalar] Azimuth faced by the surface; 0-360 (in degrees)
%     alternatively, one may specify azim/along/across angles:
%      .azim: [scalar] Fixed track azimuth; 0-360, or +/- 180 (degrees)
%      .along [scalar] Along-track tilting; +/- 90 (degrees)
%      .across [scalar] Across-track tilting; +/- 90 (degrees)
%     if .fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem:
%      .type: [char] Type of digital elevation model ('poly', 'grid')
%       if .type = 'poly':
%        .coeff: [matrix] Polynomial coefficients (see format in polyval2.m)
%       if .type = 'grid':
%        .grid: [structure] gridded surface, ready for interpolation
%          .x, .y, .z: [matrix] (see format in interp2.m)
%      .approximateit: [scalar] approximate the location of the reflection points; it helps convergence (logical/Boolean)
%     endif
%      .fnc_snr_setup_sfc_material: [function handle] Function responsible for setting up the surface material composition (@snr_setup_sfc_material_{halfspaces, slab, layered, stacked, interpolated, parametric})
%      .vert_datum: [char] Vertical datum for antenna height (sett.ref.height_ant): top or bottom interface of the middle medium (of a given thickness)? useful for soil and snow, resp. ('top', 'bottom')
%      .material_middle: [struct] Medium sandwiched between top and bottom halfspaces
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_halfspaces:
%      .material_middle: (empty in this setup)
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_slab:
%      .material_middle: (scalar structure)
%        .thickness: [scalar] middle medium thickness (in meters)
%        .name: [char] middle medium material name (see get_permittivity.m for values and extra fields)
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_layered:
%      .material_middle: (scalar structure)
%        .thickness: [vector] middle media thicknesses (in meters)
%        .name: [cell] middle media material names
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_stacked:
%      .material_middle: (vector structure)
%      .material_middle(k): k-th middle medium
%        .fnc_snr_setup_sfc_material: [function handle] k-th middle medium's own material setup function
%        .depth_min: [scalar] minimum depth (in meters)
%        .thickness: [empty, scalar, vector]
%        .name: [char, cell]
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_interpolated:
%      .material_middle: (scalar structure)
%        .thickness: [EMPTY]
%        .name: [char] middle medium material name
%        .property_name: [char] name of material property to interpolate (e.g., 'moisture', 'density', etc.)
%        .property_sample: [vector] known property values
%        .property_depth: [vector] depths where material property was sampled (in meters)
%        .depth_min: [scalar] minimum depth to interpolate; the top interface is at zero (in meters)
%        .depth_max: [scalar] maximum depth to interpolate; total tickness equals depth_max minus depth_min (in meters)
%        .depth_step: [scalar] step depth to interpolate; each layer tickness depth_step (in meters)
%        .interp_method: [char] interpolation method ('linear', 'cubic', 'spline'; see interp1.m for options)
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_parametric:
%      .material_middle: (scalar structure)
%        .thickness: [EMPTY]
%        .name: [char] middle medium material name
%        .property_name: [char] name of material property that parametric model refers to (e.g., 'moisture', 'density', etc.)
%        .property_param: [any] user-defined parameters defining dependecy of propert values on depth.
%        .fnc_property: [function handle] function outputting material property values given input of depth and property parameters.
%        .depth_min: [scalar] minimum depth to interpolate; the top interface is at zero (in meters)
%        .depth_max: [scalar] maximum depth to interpolate; total tickness equals depth_max minus depth_min (in meters)
%        .depth_step: [scalar] step depth to interpolate; each layer tickness depth_step (in meters)
% 
%    .bias: [structure] Empirical biases (see snr_bias_settings.m for details)
% 
% SEE ALSO: snr_setup

    %%
    sett = struct();
    % Angles are always in degrees, lengths/offsets/heights/delays in meters.
    % Empty means take default values.
   
    %% Satellite observation conditions:
    sett.sat = struct();
    %sett.sat.elev = [];  % let the user set it.
    %sett.sat.azim = [];
    %sett.sat.epoch = [];
    sett.sat.num_obs = [];
    sett.sat.elev_lim = [];
    sett.sat.azim_lim = [];
    sett.sat.epoch_lim = [];
    sett.sat.regular_in_sine = [];
    
    %% Reference system:
    sett.ref = struct();
    sett.ref.height_ant = 2.0;
    sett.ref.height_off = 0;
    sett.ref.velocity = [];
    sett.ref.dist_arp_pivot = 0;
    sett.ref.ignore_vec_apc_arp = false;

    %% General options:
    sett.opt = struct();
    sett.opt.gnss_name = '';
    sett.opt.freq_name = '';
    sett.opt.channel = [];
    sett.opt.code_name = '';
    sett.opt.subcode_name = '';
    sett.opt.block_name = '';
    sett.opt.incid_polar_power = [];
    sett.opt.incid_polar_phase = [];
    sett.opt.special_fringes = 'common';
    sett.opt.disable_incident_power_trend = false;
    sett.opt.disable_tracking_loss = false;
    sett.opt.extrap_tracking_loss = [];
    sett.opt.phase_approx_small_power = false;
    sett.opt.max_plot = false;
    sett.opt.num_specular_max = 1;
    
    %% Code modulation options:
    sett.opt.dsss.disable = false;
    sett.opt.dsss.assume_zero = false;
    sett.opt.dsss.approx_small_delay = false;
    sett.opt.dsss.approx_small_power = false;
    sett.opt.dsss.iterate = true;
    sett.opt.dsss.delay_tol = [];
    sett.opt.dsss.correlator_spacing_in_chips = 1;
    sett.opt.dsss.discriminator_type = [];
    sett.opt.dsss.neglect_doppler = [];
    sett.opt.dsss.coherent_integration_time = [];
    
    %% Receiver options:
    sett.opt.rec = struct();
    sett.opt.rec.temperature_noise = 470;  % (471.305 K is from Misra & Enge, sec. 10.4)
    sett.opt.rec.bandwidth_noise = 1;  % nominal
    sett.opt.rec.ant_density_noise_db = -208.8;  % (-208.8 dB-W/Hz ~ 100 K is from Langley, 1997)
    %sett.opt.rec.ant_density_noise_db = decibel_power(290*get_standard_constant('Boltzmann'));  % hardward simulator at room temperature
    sett.opt.rec.ant_density_noise_db = decibel_power(75*get_standard_constant('Boltzmann'));

    %% Undocumented options -- please ignore.
    sett.opt.layered_reflection_code = '';  % (Please ignore; 'Orfanidis', 'Zavorotny', 'Zavorotny2')
    sett.opt.disable_visibility_test = false;  % Disable shadowing and occlusion tests (in geometric optics)?
    sett.opt.occlusion = struct();  % Occlusion test (in physical optics).
    sett.opt.occlusion.disabled = false;  % Disable occlusion test? (it's expensive)
    %sett.opt.occlusion.type = [];  % ('none', 'direct', 'reflection', 'incident', 'scattered')
    %sett.opt.occlusion.dist_max_direct = 100;
    %sett.opt.occlusion.step = 5;
    %sett.opt.occlusion.interp_method = '';    

    %% Physical Optics options -- undocumented:
    sett.opt.po = struct();
    sett.opt.po.dist_sat_direct = [];
    sett.opt.po.patch_lim = [];
    sett.opt.po.approximate_dir_sat = [];
    sett.opt.po.use_two_angle_roughness = [];
    sett.opt.po.account_for_2nd_obliquity = [];
    sett.opt.po.apply_fraunhofer = [];
    sett.opt.po.plotit = [];
    sett.opt.po.clear = [];
    sett.opt.po.lim = [];
    sett.opt.po.step_in_wavelengths = [];
    sett.opt.po.zero_center_domain = [];
    sett.opt.po.do_full_pre = [];
    sett.opt.po.fresnel_zone_max = [];
    sett.opt.po.taper_gaussian_sigma_in_wavelengths = [];
    sett.opt.po.taper_gaussian_hsize_in_sigmas = [];
    sett.opt.po.apply_taper = [];
    sett.opt.po.apply_proj_scatt_normal = [];    
    sett.opt.po.check_mistrunc = [];
    
    %% Antenna electromagnetic response:
    sett.ant = struct();
    sett.ant.slope = 0;
    sett.ant.aspect = 0;
    sett.ant.axial = 0;
    sett.ant.model = 'TRM29659.00';  sett.ant.radome = 'SCIT';  % @LOW3
    %sett.ant.model = 'TRM41249.00';  sett.ant.radome = 'NONE';  % @NWOT
    sett.ant.sph_harm_degree = [];
    sett.ant.switch_left_right = false;
    sett.ant.load_redundant = false;
    sett.ant.load_extended = true;
    sett.ant.rhcp_phase = [];
    sett.ant.polar_phase = [];

    %% Reflecting surface/medium:
    sett.sfc = struct();
    sett.sfc.material_top = 'air';
    sett.sfc.material_bottom = 'medium dry/wet ground';
    sett.sfc.height_std = 10e-2;
    sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_horiz;  % _horiz, _tilted, _dem.
    
    %% Surface geometry:
    % (Non-horizontal geometry not made available at this time.)
    %sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
    %  sett.sfc.slope = 0;
    %  sett.sfc.aspect = 0;
    %  % ALTERNATIVELY:
    %  sett.sfc.azim = [];
    %  sett.sfc.along = [];
    %  sett.sfc.across = [];
    %sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
    %  sett.sfc.type = 'poly';
    %  sett.sfc.slope = [];  sett.sfc.coeff = rand(3,1);
    %sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
    %  sett.sfc.type = 'grid';
    %  sett.sfc.slope = [];  
    %  sett.sfc.grid = struct('x',rand, 'y',rand, 'z',rand, 'method',[]);
    %  sett.sfc.approximateit = '';
    %  sett.sfc.cropit = true;
    
    %% Surface layered composition:
    % (Non-homogeneous media not made available at this time.)
    sett.sfc.fnc_snr_setup_sfc_material = @snr_setup_sfc_material_halfspaces;  % _slab, _layered, _stacked, _interpolated, _parametric.
    sett.sfc.material_middle = [];
    sett.sfc.vert_datum = [];

    %% Biases:
    sett.bias = snr_bias_settings();
end

