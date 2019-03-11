function setup = snr_setup (sett)
%SNR_SETUP: Prepare GNSS multipath simulator for a subsequent run.
% 
% SYNTAX:
%    setup = snr_setup ();
%    setup = snr_setup (sett);
%
% INPUT:
%     sett: [structure] Output of function snr_settings (possibly user-modified)
%
% OUTPUT:
%    setup: [structure] Model setup data.
%
% EXAMPLE:
%    sett = snr_settings ();
%    sett.ref.height_ant = 5.0;
%    setup = snr_setup (sett)
%    result = snr_fwd (setup);
%
% REMARKS:
% - A call with no input argument will use the default settings.
% - Output "setup" contains the following nested sub-structures:
%    .sat:  [structure] satellite observation conditions
%    .ref:  [structure] reference system
%    .opt:  [structure] general options
%    .ant:  [structure] antenna electromagnetic response
%    .sfc:  [structure] reflecting surface/medium
%    .bias: [structure] biases
%    .sett: [structure] a copy of the original input settings
% - Each sub-structure contains the following fields, 
%   in addition to those described in snr_settings:
% 
%    .sat: [structure] Satellite Observation Conditions
%      .epoch: [vector] epoch corresponding to each satellite direction; generated internally if not input
%      .get_direction: [function handle] function to obtain the satellite direction at an arbitrary epoch
% 
%    .ref:  [structure] Reference System
%      .vec_apc_pivot: [vector] position vector between antenna phase center and pole pivot point; standard position format (in meters)
%      .vec_arp_pivot: [vector] position vector between antenna reference point and pole pivot point; standard position format
%      .pos_origin: [vector] absolute position postulated for the origin of the reference system, located at the base of the antenna pole; standard position format
%      .dir_up: [vector] the vertical up direction vector; standard position format; it is a unity vector
%      .pos_pivot: [vector] absolute position of the pole pivot point; standard position format
%      .pos_arp: [vector] absolute position of the antenna reference point; standard position format
%      .pos_apc: [vector] absolute position of the antenna phase center; standard position format
%      .pos_ant: [vector] a copy of .pos_apc
%
%    .opt: [structure] General Options
%      .frequency: [scalar] Carrier frequency (in hertz)
%      .incident_power_min: [scalar] minimum incident power collected by an isotropic antenna, as per GPS and GLONASS ICDs (in watts -- not dBW)
%      .incident_power_min_elev: [scalar] satellite elevation angle at which .incident_power_min refers to (in degrees)
%      .incident_power_trend_data: [structure] data describing the trend of incident power versus elevation angle
%      .incident_power_trend_min: [scalar] value of the power trend evaluated at incident_power_min_elev (in watts)
%      .tracking_loss_data: [scalar] data describing tracking losses, such as PLL vs. Costas loop; a negative value indicates a gain (in decibels)
%      .tracking_loss_data: [struct] data describing other tracking losses
%      .wavelength: [scalar] Carrier wavelength (in meters)
% 
%    .ant: [structure] Antenna Electromagnetic Response
%      .dir_nrml: [structure] boresight direction ...
%        .azim: [scalar] ... its azimuth; north is zero, east is 90 (in degrees)
%        .elev: [scalar] ... its elevation angle; zenith is 90, horizon is zero (in degrees)
%        .cart: [vector] ... in standard position format (in meters)
%        .sph:  [vector] ... in local spherical coordinates; azimuth, elevation, unity distance (in degrees )
%      .eff_area_iso: [scalar] isotropic effective area (in meters squared)
%      .eff_len_norm_iso: [scalar] isotropic complex vector effective length norm (in meters)
%      .gain, .phase: [structure] gain, phase pattern
%        .eval: [function handle] function that returns gain, phase at input polarization and viewing direction
%        .rhcp, .lhcp [structure] RHCP, LHCP gain data
%          .filename: [char] filename where data is stored
%      .rot: [matrix] rotation matrix from local frame to antenna frame; 3-by-3 size; it is an orthogonal matrix
%      .snr_fwd_direction_local2ant: [function handle] function to convert direction from local to antenna frame
%      .vec_apc_arp_upright: [vector] position vector between antenna phase center and antenna reference point, before rotation; standard position format (in meters)
% 
%    .sfc: [structure] Reflecting Surface/Medium
%      .fnc_get_reflection_coeff: [function handle] function that returns reflection coefficient for the given medium
%      .permittivity_top: [scalar] Top half-space permittivity (complex-valued)
%      .permittivity_bottom: [scalar] Bottom half-space permittivity (complex-valued)
%      .permittivity: a copy of permittivity_bottom
%      .pos_sfc0: [vector] absolute position of the intersection of the top-most surface with the antenna pole; standard position format; coincides with ref.pos_origin only when sfc.vert_datum = 'top'
%      .height_ant_sfc: [scalar, vector] vertical distance between antenna phase center and top-most surface immediately under it (in meters); for tilted surfaces, it differs from the perpendicular distance; it is output as a scalar if sett.ref.height_off was input as a scalar, too.
%      .dir_nrml: [vector] the surface normal direction; standard position format; it is a unity vector
%      .snr_fwd_direction_local2sfc: [function handle] function that converts a direction from the local frame (north, east, up) to the surface frame
%      .snr_fwd_divergence: [function handle] function that returns the ray divergence
%      .snr_fwd_geometry_reflection: [function handle] function that returns the direction from antenna to reflection point on the surface, the absolute position of the reflection point, and the interferometric propagation delay, given a satellite direction
%      .snr_fwd_geometry_sfc_height: [function handle] function that returns surface height at an arbitrary horizontal position
%      .snr_fwd_visibility: [function handle] function to check for visibility
%      .thickness_total: [scalar] total thickness of middle medium (in meters)
%      .num_specular_max: [scalar] maximum number of simultaneous specular reflections supported by surface model (>=1)
%     if .fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted:
%      .rot: [matrix] rotation matrix from local frame to surface frame; 3-by-3 size; it is an orthogonal matrix
%      .pos_ant_sfc: [vector] absolute position of the orthogonal projection of the antenna on the surface; standard position format
%      .pos_ant_img: [vector] absolute position of the antenna image or virtual antenna; standard position format
%     if .fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem:
%      .snr_fwd_geometry_height_grad_aux: [function handle] auxiliary function that returns surface height gradient vector
%      .snr_fwd_geometry_height_hess_aux: [function handle] auxiliary function that returns surface height Hessian matrix
%      .snr_fwd_geometry_height_self_aux: [function handle] auxiliary function that returns surface height itself
%      .approx: [structure] surface approximation to DEM in which reflection points can be calculated in closed form
%      .height0: [scalar] raw height evaluated at pos_sfc0 (in meters)
%      .dem_is_relative: [scalar] is the DEM relative, i.e., subtract height0 from the DEM? (logical/Boolean)
%     if .type = 'poly':
%      .coeffs: [structure] polynomial coefficients...
%        .c: [matrix] ... of height itself
%        .cdx: [matrix] ... of height east-west gradient
%        .cdx2: [matrix] ... of height east-west curvature
%        .cdy: [matrix] ... of height north-south gradient
%        .cdy2: [matrix] ... of height north-south curvature
%        .cdxy: [matrix] ... of height cross curvature
%     if .type = 'grid':
%      .grid: [structure] interpolation grid...
%        .x: [matrix] ... of east-west coordinates
%        .y: [matrix] ... of north-south coordinates
%        .z: [matrix] ... of height itself
%        .dz_dx: [matrix] ... of height east-west gradient
%        .dz_dy: [matrix] ... of height north-south gradient
%        .dz2_dx2: [matrix] ... of height east-west curvature
%        .dz2_dxy: [matrix] ... of height cross curvature
%        .dz2_dyx: [matrix] ... of height cross curvature
%        .dz2_dy2: [matrix] ... of height north-south curvature
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_halfspaces:
%      .permittivity_middle: (empty in this setup)
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_slab:
%      .permittivity_middle: [scalar] Middle medium permittivity (complex-valued)
%      .depth_midpoint: [scalar] depth of vertical center of middle medium (in meters)
%      .depth_interface: [vector] depth of middle medium top and bottom interfaces (in meters)
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_layered:
%      .permittivity_middle: [vector] as above, except for number of elements
%      .depth_midpoint: [vector] as above, except for number of elements
%      .depth_interface: [vector] as above, except for number of elements
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_stacked:
%      .permittivity_middle, .depth_midpoint, .depth_interface: as above
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_interpolated:
%      .permittivity_middle, .depth_midpoint, .depth_interface: as above
%      .property_eval: [vector] material property interpolated at each layer
%     if .fnc_snr_setup_sfc_material = @snr_setup_sfc_material_parametric:
%      .permittivity_middle, .depth_midpoint, .depth_interface, .property_eval: as above
%
%    .bias: [structure] User-defined Biases
%      .indep: [vector] polynomial independent variable at each satellite direction
%      .indep_fnc: [function handle] function that returns .indep above
% 
% SEE ALSO: snr_settings, snr_fwd, snr_resetup.

    %%
    if (nargin < 1) || isempty(sett),  sett = snr_settings();  end
    if iscell(sett),  setup = cell_snr_setup (sett);  return;  end
    sett = snr_deprecated   (sett);
    sat  = snr_setup_sat    (sett.sat);
    opt  = snr_setup_opt    (sett.opt);
    bias = snr_setup_bias   (sett.bias, sat, opt);
    ant  = snr_setup_ant    (sett.ant, opt.freq_name, opt.channel, sett.ref.ignore_vec_apc_arp);
    ref  = snr_setup_origin (sett.ref, ant.vec_apc_arp_upright, ant.rot, sat.epoch);
    sfc  = snr_setup_sfcs   (sett.sfc, opt.frequency, ref);
    setup = struct('sat',sat, 'sfc',{sfc}, 'ref',ref, 'ant',ant, 'opt',opt, 'bias',bias);
    %setup = struct('sat',sat, 'sfc',sfc, 'ref',ref, 'ant',ant, 'opt',opt, 'bias',bias);  % WRONG!
    setup.sett = sett;  % (keep a copy of input)
end
