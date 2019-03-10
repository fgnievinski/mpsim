%%
obs = load(fullfile(fileparts(mfilename('fullpath')), '..', 'snr_s2_vs_sc_obs.mat'));
ind = argsort(obs.elev);
obs = structfun(@(f) f(ind), obs, 'UniformOutput',false);
idx = (obs.elev > 1);
obs = structfun(@(f) f(idx), obs, 'UniformOutput',false);

%%
sett0 = snr_settings();
sett0.opt.height_ant = 1.85;
sett0.opt.height_ant = 1.5;
sett0.sat.elev = obs.elev;
%sett0.bias.fixed = 0;  % will triger warning ID 'snr:snr_fwd_tracking_loss:Extrap'.
sett0.bias.fit.elev_cutoff_reflected = [0 15];
sett0.bias.fit.degree_trend = 1;

%%
sett_sc_pre = sett0;
%sett_sc_pre.bias.fit.plotit = true;
%sett_sc_pre.bias.indep_type = 'sing';
%sett_sc_pre.bias.indep_type = 'sine';
%sett_sc_pre.bias.indep_type = 'elev';
%sett_sc_pre.bias.indep_type = 'zen';
[sett_sc_post, snr_simul_db_post, snr_simul_trend_post, snr_meas_detrended_post] = snr_fwd_bias_fit (obs.sc, sett_sc_pre);
%sett_sc_pre.bias
sett_sc_post.bias

figure
  hold on
  plot(obs.elev, obs.sc, '.-k')
  plot(obs.elev, decibel_power(snr_simul_trend_post), '-b', 'LineWidth',2)
  plot(obs.elev, snr_simul_db_post, '-r', 'LineWidth',2)
  grid on, maximize()

%%
%sett_sc_post.opt.disable_fringes = true;
sett_sc_post.opt.disable_fringes = false;
sett_sc_post.opt.max_fringes = true;
setup_sc_post = snr_setup(sett_sc_post);
snr_simul_db_post2 = getfield(snr_fwd(setup_sc_post), 'snr_db');
%
figure
  hold on
  plot(obs.elev, obs.sc, '.-k')
  plot(obs.elev, decibel_power(snr_simul_trend_post), '-b', 'LineWidth',2)
  plot(obs.elev, snr_simul_db_post2, '-r', 'LineWidth',2)
  grid on, maximize()

%%
sett_s2_pre = sett0;
sett_s2_pre.opt.code_name = 'P(Y)';
sett_s2_pre.opt.disable_tracking_loss = false;  sett_s2_pre.bias.fit.degree_trend = 2;
%sett_s2_pre.opt.disable_tracking_loss = true;   sett_s2_pre.bias.fit.degree_trend = 5;
sett_s2_pre.bias.fit.elev_cutoff_reflected = [0 15];
%sett_s2_pre.bias.apply_direct_power_bias_only_at_end = false;
%sett_s2_pre.bias.fit.plotit = true;
[sett_s2_post, snr_simul_db_post, snr_simul_trend_post, snr_meas_detrended_post] = snr_fwd_bias_fit (obs.s2, sett_s2_pre);

%
figure
  hold on
  plot(obs.elev, obs.s2, '.-k')
  plot(obs.elev, decibel_power(snr_simul_trend_post), '-b', 'LineWidth',2)
  plot(obs.elev, snr_simul_db_post, '-r', 'LineWidth',2)
  grid on, maximize()
