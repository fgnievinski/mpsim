function [r,g,b]=indexed2hexcolor(indColor)

d=strread(indColor,'C-%d',1)-256^3;

r = floor(-d/256^2);
d = d+r*256^2;

g = floor(-d/256);
d = d+g*256;

b = floor(-d/1);


% ind=1+(255-r)*256^2+(255-g)*256^1+(255-b)*256^0






% C-16777216:   0,  0,  0   %black
%  C-5075968: 178,140,  0
%   C-197412:
%  C-6283024:
% C-16776961:   0,  0,255   %blue




