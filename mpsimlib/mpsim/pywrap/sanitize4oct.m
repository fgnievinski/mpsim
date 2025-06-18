function strc = sanitize4oct(istruct)

strc=istruct;
for [val,key] = istruct
  if ischar(val) && length(val) > 0 && strcmp(val(1), "@") == 1
    strc=setfield(strc,key,str2func(val(2:end)));
  end
  if strcmp(typeinfo(val),'scalar struct') == 1
    % recursively sanitize the struct
    strc=setfield(strc,key,sanitize4oct(val));
  end

end


