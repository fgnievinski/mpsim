% Measured discrepancy between SNR of L2-P(Y) and of L2C, versus SNR of
% L2C; based on observations collected simultaneously for both codes at
% 10-second intervals during a full day (24 Mar 2009) at a fixed station
% (receiver Trimble NetRS, station P041 of the Plate Boundary Observatory,
% http://pbo.unavco.org) for all block IIR-M satellites active at the time
% (PRNs 7, 12, 15, 17, 29, and 31)
% 
% Inset in Fig. 3 in Nievinski, F.G. and Larson, K.M., "An open source GPS
% multipath simulator in Matlab/Octave", GPS Solut. (in press)

%%
temp = load('snr_s2_vs_sc_obs.mat');
sc = temp.sc;
s2 = temp.s2;
elev = temp.elev;

idx = isnan(sc) | isnan(s2) | isnan(elev);
sc(idx) = [];
s2(idx) = [];
elev(idx) = [];

sd = s2 - sc;

%%
% figure
%   hold on
%   plot(elev, s2, '.r')
%   plot(elev, sc, '.b')
%   legend({'P(Y)','L2C'}, 'Location','SouthEast')
%   grid on
%   xlabel('Elevation angle (degrees)')
%   ylabel('SNR (dB)')
%   xlim([0 90])

%%
figure
  hold on
  plot(sc, sd, '.k')
  grid on
  axis equal
  xlabel('SNR-L2C (dB)')
  ylabel('SNR-P(Y) minus SNR-L2C (dB)')
  mysaveas('figB3inset')
