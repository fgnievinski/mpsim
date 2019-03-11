function local = rinex2aziele (obs_filename, orb_filename, site_pos_cart)
% Demo::
%   obs_filename = 'unbj2480.10o';
%   orb_filename = 'igs16000.sp3';
%   site_pos_cart = [1761288.2958 -4078237.0520  4561418.1338];
%   local = rinex2aziele (obs_filename, orb_filename, site_pos_cart)

obs = read_rinex_obs2(obs_filename);
orb = read_orbit_file(orb_filename);

site = struct();
site.pos_cart = site_pos_cart;
site.ell = get_ellipsoid('grs80');
site.pos_geod = convert_to_geodetic(site.pos_cart, site.ell);

local = get_obs_local_coord (site, obs, orb);
local.azim = local.data(:,strcmp(answer.info.obs_type, 'azimuth'));
local.elev = local.data(:,strcmp(answer.info.obs_type, 'elevation'));

end
