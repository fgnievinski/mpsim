function name = getComputerName(makeItLower)
% GETCOMPUTERNAME returns the name of the computer (hostname)
% name = getComputerName()
%
% WARN: output string is converted to lower case
%
%
% See also SYSTEM, GETENV, ISPC, ISUNIX
%
% m j m a r i n j (AT) y a h o o (DOT) e s
% (c) MJMJ/2007
%

if (nargin < 1) || isempty(makeItLower),  makeItLower = true;  end

[ret, name] = system('hostname');

if ret ~= 0
   if ispc()
      name = getenv('COMPUTERNAME');
   else
      name = getenv('HOSTNAME');
   end
end

name = deblank(name);
%name = strtrim(name);  % no need to remove leading blanks, only trailing ones.

if makeItLower,  name = lower(name);  end


