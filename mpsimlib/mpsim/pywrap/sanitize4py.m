function strc = sanitize4py(istruct)

strc=istruct;
for [val,key] = istruct
  if is_function_handle(val) == 1
    %just convert the function to a string
    strc=setfield(strc,key,strcat("@",func2str(val)));
  end
  if strcmp(typeinfo(val),'scalar struct') == 1
    % recursively sanitize the struct
    strc=setfield(strc,key,sanitize4py(val));
  end

end

