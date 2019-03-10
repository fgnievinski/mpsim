function sett = snr_settings_paper ()
%SNR_SETTINGS_PAPER: Return settings for GPS multipath simulator examples.
% 
% SYNTAX:
%    sett = snr_settings ();
%
% INPUT: none    
%
% OUTPUT:
%    sett: [structure] default settings, as returned by snr_settings
%
% SEE ALSO: snr_settings

  %%
  sett = snr_settings();
  sett.ref.height_ant = 1.5;
  sett.sat.elev_lim = [0, 90];
  sett.sat.num_obs = 500;
  %sett.sfc.height_std = 0;
  sett.opt.max_plot = false;
end
