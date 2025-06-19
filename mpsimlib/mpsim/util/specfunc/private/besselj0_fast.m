function y = besselj0_fast (x)
    if isa(x, 'double')
        try
            y = besselj0_fast_c(x);
            return
        catch
        end
    end
    y = besselj0_fast_m(x);
end

%!test
%! x = (0:0.1:5)';  % sample all cases.
%! for prec={'double','single'},  prec=prec{1};
%!     %prec  % DEBUG
%!     x = cast(x, prec);
%!     tol = sqrt(eps(prec));
%!     out = besselj (0, x);
%!     out2 = besselj0_fast (x);
%!     %[x, out, out2, out2-out]  % DEBUG
%!     myassert(out2, out, -tol)
%!     myassert(isa(out,  prec))
%!     myassert(isa(out2, prec))
%! end

