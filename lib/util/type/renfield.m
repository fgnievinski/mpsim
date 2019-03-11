function s = renfield (s, n1, n2)
%RENFIELD  Rename structure field.
% 
% See also: RMFIELD.

    if isscalar(s)
        s = setfield(s, n2, s.(n1));
    else
        tmp = {s.(n1)};
        N = numel(tmp);
        %s = setfield(s, num2cell(1:N), n2, tmp);  % WRONG!
        s = setfield(s, {1}, n2, []);
        for i=1:N,  s(i).(n2) = tmp{i};  end
    end
    
    s = rmfield(s, n1);
end

%!test
%! myassert(renfield(struct('a',[]), 'a', 'b'), struct('b',[]))

%!test
%! in = struct();
%! in.a = 1;
%! in(2).a = 2;
%! out = struct();
%! out.b = 1;
%! out(2).b = 2;
%! out2 = renfield(in, 'a', 'b');
%! %keyboard  % DEBUG
%! myassert(out2, out)

%!test
%! in = struct();
%! in.a = 'AB';
%! in(2).a = 'CD';
%! out = struct();
%! out.b = 'AB';
%! out(2).b = 'CD';
%! out2 = renfield(in, 'a', 'b');
%! %keyboard  % DEBUG
%! myassert(out2, out)

