function out = structfunrecurse (fun, in)
    out = structfun(@(f) fun2(fun, f), in, 'UniformOutput',false);
end

function fout = fun2 (fun, fin)
    if ~isstruct(fin),  fout = fun(fin);  return;  end
    fout = structfunrecurse (fun, fin);
end
