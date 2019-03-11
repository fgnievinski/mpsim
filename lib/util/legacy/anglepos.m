function out = anglepos (in)
    out = angle(in);
    %return;  % DEBUG
    idx = (out < 0);
    out(idx) = 2*pi + out(idx);
end

%!test
%! n = ceil(10*rand);
%! n = 1000;
%! angle_in = randint(0, 2*pi, n, 1);
%! angle_out = anglepos(exp(1i * angle_in));
%! %[angle_in, angle_out, angle_out - angle_in]  % DEBUG
%! myassert(angle_out, angle_in, -eps(angle_in))

