function strc = sanitize4py(istruct)

global mpsimflookup;

strc=istruct;
for [val,key] = istruct
  if is_function_handle(val) == 1
    %just convert the function to a string
    %store the function in the global lookup
    fname=strcat("@",func2str(val));
    if isfield(mpsimflookup,fname)
    warning("overwriting existing function in global lookup table: %s", fname);
    endif  
    mpsimflookup=setfield(mpsimflookup,fname,val);
    
    %store the fieldname as a string
    strc=setfield(strc,key,fname);
  end
  if strcmp(typeinfo(val),'scalar struct') == 1
    % recursively sanitize the struct
    strc=setfield(strc,key,sanitize4py(val));
  end

end

