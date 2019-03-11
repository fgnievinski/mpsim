function [out1, out2] = uniquem (in1, in2)
    [out1, num, m, n] = unique2 (in1);
    out2 = in2(m);
    p = find(num > 1);
    if isempty(p),  return;  end
    for i=1:numel(p)
        q = p(i);
        out2(q) = mean(in2(n == q));
    end
end

%!test
%! in1 = [0 1 1 2 2 3];
%! in2 = rand(size(in1))
%! out1 = [0 1 2 3];
%! out2 = [in2(1), mean(in2(2:3)), mean(in2(4:5)), in2(6)];
%! [out1b, out2b] = uniquem (in1, in2);
%! myassert(out1b, out1)
%! myassert(out2b, out2)
