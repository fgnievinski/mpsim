function out = func2str2 (in)
    if ~isa(in, 'function_handle'),  out = in;  return;  end
    out = func2str(in);
end

