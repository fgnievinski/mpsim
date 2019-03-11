function out = sincnopi (in)
    out = sinc (in ./ pi);
    %out = sinc (in ./ pi) .* pi;  % WRONG!
end

%!test
%! function out = sincnopi2 (in)
%!     out = sin (in) ./ in;
%! end
%! 
%! n = 10;
%! in = randint(-1,+1, n,1);
%! out = sincnopi(in);
%! out2 = sincnopi2(in);
%! %out2-out  % DEBUG
%! myassert(out2, out, -sqrt(eps()))


