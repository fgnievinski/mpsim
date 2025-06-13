function dms = deg2dms(ddeg, n)
    mat = deg2mat(ddeg);
    if (nargin > 1),  mat = mat_round(mat, n);  end
    dms = mat2dms(mat);
end

%!test
%! deg = [0; -90; 90.5; -(90+1/3600); -(1/60); 180; 1; (90+1/60)];
%! dms = [0.0; -90.0; 90.300; -90.0001; -00.0100; 180.0; 1; 90.0100];
%! dms2 = deg2dms (deg);
%! %dms, dms2, dms2 - dms  % DEBUG
%! myassert (dms2, dms, -eps);

%!test
%! n = ceil(10*rand);
%! temp = rand(n,1);
%! sig = ones(n,1);  sig(temp>0.5) = -1;
%! deg = ceil(rand(n,1)*180);
%! min = ceil(rand(n,1)*60);
%! sec = rand(n,1)*60;
%! 
%! idx = sec == 60;  min(idx) = min(idx) + 1;  sec(idx) = 0; 
%! idx = min == 60;  deg(idx) = deg(idx) + 1;  min(idx) = 0; 
%! 
%! ddeg = sig .* (deg + (min + sec/60)/60);
%! dms  = sig .* (deg + (min + sec/100)/100);
%! 
%! dms2 = deg2dms(ddeg);
%! err = dms2 - dms;
%! %idx = err > 1000*eps;
%! %err(idx), [dms(idx), dms2(idx)], [deg(idx), min(idx), sec(idx)]
%! myassert (err, 0, -1000*eps);

%!test
%! ddeg = 90+1.111/3600;
%! dms2 = deg2dms(ddeg);
%! dms = 90.0001111;
%! %dms, dms2, dms2 - dms  % DEBUG
%! myassert(dms2, dms, -sqrt(eps))

%!test
%! ddeg = 90+1.111/3600;
%! dms2 = deg2dms(ddeg, -1);
%! dms = 90.0001100;
%! %dms, dms2, dms2 - dms  % DEBUG
%! myassert(dms2, dms, -sqrt(eps))
