function out = rmfieldifexist (in, fr)
    if ~iscell(fr),  fr = {fr};  end
    fe = fieldnames(in);
    fr(~ismember(fr, fe)) = [];
    out = rmfield (in, fr);
end

%!test
%! in = struct('a',1, 'b',2);
%! 
%! out = struct('a',1);
%! out2 = rmfieldifexist (in, 'b');
%! myassert(out2, out)
%! 
%! out = struct();
%! out2 = rmfieldifexist (in, {'a','b'});
%! myassert(out2, out)
%! 
%! out = in;
%! out2 = rmfieldifexist (in, {'c'});
%! myassert(out2, out)
