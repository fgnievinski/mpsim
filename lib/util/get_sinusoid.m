function [sinus, phase, dS_dA, dS_dp, dS_df] = get_sinusoid ()
    phase = @(A, p, f, t) 360*f.*t + p;  % input phase-shift is in degrees!  f*t is in cycles!
    sinus = @(A, p, f, t) A.*cos(phase(A, p, f, t)*pi/180);
    dS_dA = @(A, p, f, t) sinus(A, p, f, t)./A;  % = cos(2*pi*f.*t + p*pi/180);
    dS_dp = @(A, p, f, t) sinus(A, p+90, f, t)*pi/180;  % -A.*sin(2*pi*f.*t + p*pi/180);
    dS_df = @(A, p, f, t) sinus(A, p+90, f, t).*2*pi.*t;  % = -A.*sin(2*pi*f.*t + p*pi/180).*2*pi*t;
end

%!test
%! [sinus, phase, dS_dA, dS_dp, dS_df] = get_sinusoid ();
%! [A,f,p] = deal2(rand(1,3));
%! t = rand(10,1);
%! 
%! dS_dA_val = dS_dA(A, p, f, t);
%! dS_df_val = dS_df(A, p, f, t);
%! dS_dp_val = dS_dp(A, p, f, t);
%! 
%! dS_dA_val2 = diff_func (@(A) sinus(A, p, f, t), A);
%! dS_dp_val2 = diff_func (@(p) sinus(A, p, f, t), p);
%! dS_df_val2 = diff_func (@(f) sinus(A, p, f, t), f);
%! 
%! %[dS_dA_val, dS_dA_val2, dS_dA_val2-dS_dA_val]  % DEBUG
%! %[dS_df_val, dS_df_val2, dS_df_val2-dS_df_val]  % DEBUG
%! %[dS_dp_val, dS_dp_val2, dS_dp_val2-dS_dp_val]  % DEBUG
%! 
%! tol = -sqrt(eps());
%! myassert(dS_dA_val, dS_dA_val2, tol)
%! myassert(dS_df_val, dS_df_val2, tol)
%! myassert(dS_dp_val, dS_dp_val2, tol)

