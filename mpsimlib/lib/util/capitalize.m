function out = capitalize (in)
    if iscell(in),  out = cellfun2(@capitalize, in);  return;  end
    myassert(ischar(in))
    if isempty(in)
        out = in;
        return;
    end
    out = [upper(in(1)), lower(in(2:end))];
end
