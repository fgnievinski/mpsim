% SNR simulations for the same carrier frequency (L2) and receiving antenna
% (TRM29659.00) but different code modulations. Inset: measured discrepancy
% between SNR of L2-P(Y) and of L2C, versus SNR of L2C; based on
% observations collected simultaneously for both codes at 10-second
% intervals during a full day (24 Mar 2009) at a fixed station (receiver
% Trimble NetRS, station P041 of the Plate Boundary Observatory,
% http://pbo.unavco.org) for all block IIR-M satellites active at the time
% (PRNs 7, 12, 15, 17, 29, and 31)
% 
% Fig. 3 in Nievinski, F.G. and Larson, K.M., "An open source GPS multipath
% simulator in Matlab/Octave", GPS Solut. (in press)

if is_octave()
  figB3main
  figB3inset
  return;
end

%%
figB3inset
  %maximize()  % force it, regardless of settings
  set(gcf(), 'Color','w')
  set(gca(), 'Box','on')
  F = getframe(gcf());
  try F.cdata = imresize(F.cdata, 0.5);  catch,  end %#ok<CTCH>
  
%%
figB3main
  temp = [0.54517     0.036205      0.38519      0.58277];
  ah = axes('Position',temp);
  image(F.cdata),  colormap(F.colormap)
  axis equal
  axis image  
  set(ah, 'XTick',[], 'YTick',[])
  set(ah, 'Box','off', 'XColor','w', 'YColor','w', 'Color','w')
  set(gcf(), 'Color','w', 'InvertHardCopy','off')
  mysaveas('figB3')
