function strc = sanitize4oct(istruct)

global mpsimflookup;

strc=istruct;
for [val,key] = istruct
  if ischar(val) && length(val) > 0 && strcmp(val(1), "@") == 1
    if isfield(mpsimflookup,val)
      % retrieve the function from the global lookup
      fnc=getfield(mpsimflookup,val);
    else
       
      error("Function not found in global lookup table.",key);
    end
    strc=setfield(strc,key,fnc);
  end
  if strcmp(typeinfo(val),'scalar struct') == 1
    % recursively sanitize the struct
    strc=setfield(strc,key,sanitize4oct(val));
  end

end


