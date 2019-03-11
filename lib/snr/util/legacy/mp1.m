function [mp p2p] = mp1(L1psr, L1adr, L2adr)

% L1psr, L1adr, L2adr (m)

%Constants
c = 299792458; %speed of light in m/s
fL1 = 1.57542e9; %L1 carrier frequency
lambdaL1 = c/fL1;
fL2 = 1.2276e9;
lambdaL2 = c/fL2;

k1 = (fL1^2 + fL2^2)/(fL1^2 - fL2^2);
k2 = 2*fL2^2/(fL1^2 - fL2^2);

% L1adr = lambdaL1.*L1adr;
% L2adr = lambdaL2.*L2adr;

mp = L1psr - k1.*L1adr + k2.*L2adr;

mp(abs(mp)>1e3) = 0;

p2p = max(mp) - min(mp);

if p2p > 1e3
    p2p = NaN;
end

end
