function out = mfunctionname ()
%MFUNCTIONNAME  Name of currently running function
% 
% See also:  MFILENAME, GET_CALLER_NAME.

  s = dbstack();
  out = s(2).name;
end
