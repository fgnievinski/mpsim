function [lim, wyear0, year0] = mydatedoywi_aux2 (wyear0str)
%MYDATEDOYWI_AUX2: Auxiliary function for day of water-year conversions.
  %wyear0 = mydatedoywi_aux(wyear0str);  year0 = wyear0;  % WRONG! private fnc
  [~, wyear0] = mydatedoywi([], wyear0str);  year0 = wyear0;
  lim = [mydatedoywi(1, wyear0), mydatedoywi(1, wyear0+1)-mydatedayi(1)];
  lim(2) = lim(2) - sqrt(eps(lim(2)));  % avoid doyw=0 at the end.
end
