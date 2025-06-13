function out = defrontal_pt (in)
    [m,n,p] = size(in);
    assert(m==1);
    out = reshape(in, [n, p, 1]).';
end

%!test
%! % defrontal_pt()
%! test('frontal_pt')

