function [result, snr_db, carrier_error, code_error] = snr_fwd (setup)
%SNR_FWD: Forward simulation of GNSS multipath.
% 
% SYNTAX:
%    snr_fwd ()
%    [...] = snr_fwd (setup);
%    result = snr_fwd (...);
%    [result, snr_db, carrier_error, code_error] = snr_fwd (...);
%
% INPUT:
%    setup: [structure] output of function snr_setup
%
% OUTPUT:
%    result: [structure] all final as well as intermediary results
%    snr_db: [vector] signal-to-noise ratio (in decibels)
%    carrier_error: [vector] carrier-phase error (in meters)
%    code_error: [vector] with pseudorange code error (in meters)
%
% EXAMPLE:
%    sett = snr_settings ();
%    sett.ref.height_ant = 5.0;
%    setup = snr_setup (sett)
%    result = snr_fwd (setup);
%
% REMARKS:
% - A call with no output argument will produce a plot figure.
% - A call with no input argument will use the default setup.
% - Output "result" contains the following fields:
%    .phasor_direct: [vector] direct voltage (in volts, complex-valued)
%    .phasor_reflected: [vector] reflected voltage (in volts, complex-valued)
%    .phasor_interf: [vector] interferometric voltage (unitless, complex-valued)
%    .phasor_composite: [vector] composite voltage (in volts, complex-valued)
%    .phasor_error: [vector] multipath error voltage (in volts, complex-valued)
%    .phasor_bias_reflected: [vector, or scalar if uniform] user-specified reflected bias voltage (in volts, complex-valued)
%    .phasor_bias_direct: [vector, or scalar if uniform] user-specified direct bias voltage (in volts, complex-valued)
%    .delay_direct: [vector, or scalar if uniform] direct delay (in meters)
%    .delay_reflected: [vector] reflection delay (in meters)
%    .delay_interf: [vector] interferometric delay (in meters)
%    .delay_composite: [vector] composite delay (in meters)
%    .delay_error: [vector] multipath error delay (in meters)
%    .delay_bias: [vector, or scalar if uniform] user-specified delay bias (in meters)
%    .snr_db: [vector] signal-to-noise ratio (in decibels of watts per watt)
%    .carrier_error: [vector] carrier-phase error (in meters)
%    .code_error: [vector] pseudorange code error (in meters)
%    .power_composite: [vector] composite power (in watts)
%    .power_loss: [vector] power loss, inclusive of noise, tracking, and estimator; exclusive of user-defined bias (in watts)
% - Output "result" also contains the following nested sub-structures:
%    .direct: [structure] intermediary results of direct or line-of-sight voltage
%      .phasor_antenna_rhcp: [vector] RHCP direct antenna response (in meters, complex-valued)
%      .phasor_antenna_Lhcp: [vector] LHCP direct antenna response (in meters, complex-valued)
%      .phasor_rhcp: [vector] RHCP contribution to direct voltage (in volts, complex-valued)
%      .phasor_lhcp: [vector] LHCP contribution to direct voltage (in volts, complex-valued)
%      .code: [vector] direct code-correlation function (in volts per volt, real-valued)
%      .phasor_pre: [vector] pre-correlation direct voltage (in volts, complex-valued)
%      .phasor_post: [vector] post-correlation direct voltage (in volts, complex-valued)
%    .reflected: [structure] intermediary results of reflected voltage
%      .phasor_antenna_rhcp: [vector] RHCP reflected antenna response (in meters, complex-valued)
%      .phasor_antenna_lhcp: [vector] LHCP reflected antenna response (in meters, complex-valued)
%      .phasor_fresnelcoeff_same: [vector] same-sense Fresnel reflection coefficient (unitless, complex-valued)
%      .phasor_fresnelcoeff_cross: [vector] cross-sense Fresnel reflection coefficient (unitless, complex-valued)
%      .phasor_delay: [vector] reflection propagation effect (unitless, unit-complex)
%      .phasor_roughness: [vector] reflection roughness effect (unitless, normally real-valued, possibly complex-valued if small-scale shadowing is accounted for)
%      .phasor_divergence: [vector, or scalar if uniform] reflection divergence effect (unitless, unity for flat surfaces, real-valued for concave/convex surfaces, complex-valued past caustics)
%      .phasor_nongeom: [vector] aggregate of all non-geometrical contributions to reflected voltage
%      .phasor_rhcp: [vector] RHCP contribution to reflected voltage (in volts, complex-valued)
%      .phasor_lhcp: [vector] LHCP contribution to reflected voltage (in volts, complex-valued)
%      .code: [vector] reflected code-correlation function (in volts per volt, real-valued)
%      .phasor_pre: [vector] pre-correlation reflected voltage (in volts, complex-valued)
%      .phasor_post: [vector] post-correlation reflected voltage (in volts, complex-valued)
%      .phasor_post_net: [vector] post-correlation net reflected voltage; one scalar per satellite direction (in volts, complex-valued)
%      .phasor_post_all: [matrix] post-correlation reflected voltages, for each simultaneous reflection; column vectors (in volts, complex-valued)
%    .incident: [structure] incident electric field
%      .phasor_rhcp: [vector] RHCP incident electric field (in volts per meter)
%      .phasor_lhcp: [vector] LHCP incident electric field (in volts per meter)
%    .geom: [structure] geometrical results
%      .num_dirs: [scalar] number of satellite directions
%      .num_reflections: [scalar] number of simultaneous reflections per satellite direction
%      .reflections: [structure, possibly non-scalar] reflections geometry
%       (each .reflections(1), .reflections(2), etc. is as in .reflection below)
%      .reflection: [structure, scalar] first or main reflection geometry
%        .visible: [vector] is reflection visible? (logical/Boolean)
%        .delay: [vector] reflection delay (in meters)
%        .pos: [structure] reflection position...
%          .local: [structure] ... with origin down at the base of the antenna pole
%            .cart: [matrix] local Cartesian coordinates; north, east, up (in meters)
%        .dir: [structure] reflection direction...
%          .local_ant: [structure] ... in antenna-centered coordinates
%            .elev: [vector] elevation angle; horizon is zero, zenith is 90 (in degrees)
%            .azim: [vector] azimuth; north is zero, east is 90 (in degrees)
%          .ant: [structure] ... in antenna-centered antenna-rotated coordinates
%            .elev: [vector] rotated elevation angle; antenna's equator is zero, boresight is 90 (in degrees)
%            .azim: [vector] rotated azimuth; antenna reference direction is zero (in degrees)
%        .sat_dir: [structure] direct or light-of-sight viewing direction to satellite...
%          .sfc: [structure] ... centered at reflection point and rotated as per surface tangent and curvature
%            .elev: [vector] satellite-surface grazing angle; tangent is zero, normal is 90 (in degrees)
%            .azim: [vector] azimuth-like angle; first and second principal curvature directions are zero and 90, resp. (in degrees)
%        .extra: [structure] undocumented
%      .direct: [structure] direct or line-of-sight geometry
%        .visible: [vector] is satellite directly visible? (logical/Boolean)
%        .dir: [structure] direct or line-of-sight viewing direction
%          .ant, .local_ant: format as in geom.reflection.dir
%          (geom.direct.dir.ant points to satellite, geom.reflection.dir.ant points to the surface)
%          (geom.direct.dir.ant is nearly geom.reflection.sat_dir.sfc for a horizontal surface)
%    .pre: [structure] pre-processed information; used internally to speed-up multiple similar runs
%    .sat: [structure] satellite information; copied as a convenience from input into output
% 
% SEE ALSO: snr_setup

    %%
    if (nargin < 1),  setup = snr_setup();  end
    if iscell(setup)
        [result, snr_db, carrier_error, code_error] = cell_snr_fwd (setup);
        return;
    end
    if ~isfield(setup, 'pre'),  setup.pre = struct();  end
    pre = setup.pre;
    extra = struct();
    siz = size(setup.sat.epoch);  setup.sat.epoch = setup.sat.epoch(:);
    if iscell(setup.sfc),  setup.sfc = setup.sfc{1};  end
    %setup.bias  % DEBUG
    
    if ~all(isfield(pre, {'phasor_direct','phasor_reflected','delay_reflected','doppler_reflected','geom'}))
        [pre.phasor_direct, pre.phasor_reflected, ...
          pre.delay_reflected, pre.doppler_reflected, ...
          pre.geom, extra] = snr_fwd_direct_and_reflected (setup);
    end
    r = extra;
    r.pre = pre;
    r.phasor_direct     = pre.phasor_direct;
    r.phasor_reflected  = pre.phasor_reflected;
    r.delay_reflected   = pre.delay_reflected;
    r.doppler_reflected = pre.doppler_reflected;
    geom = pre.geom;
    
    [r.phasor_direct,    r.phasor_bias_direct, ...
     r.phasor_reflected, r.phasor_bias_reflected, ...
     r.delay_reflected,  r.delay_bias] = snr_fwd_bias (...
        r.phasor_direct, r.phasor_reflected, r.delay_reflected, setup, geom);
      
    r.phasor_reflected = snr_fwd_fringe_aux (...
        r.phasor_direct, r.phasor_reflected, setup.opt.special_fringes);
    
    r = snr_fwd_combine (setup.opt, ...
        r.phasor_direct, r.phasor_reflected, ...
        r.delay_reflected, r.doppler_reflected, r);
    %[r.power_composite, r.carrier_error, r.code_error, extra2] = snr_fwd_combine (...
    %r = structmerge(r, extra2);  % slows down

    [r.snr_db, r.power_loss] = snr_fwd_signal2snr (r.power_composite, setup, geom, r.phasor_bias_direct);
    
    r.geom = geom;
    r.sat = setup.sat;
    r.sat.siz = siz;
    if (nargout < 1),  snr_fwd_plot_error (r, setup.opt.max_plot);  end
    result = r;
    if (nargout < 2),  return;  end
    snr_db        = reshape(r.snr_db,        siz);
    carrier_error = reshape(r.carrier_error, siz);
    code_error    = reshape(r.code_error,    siz);
end
