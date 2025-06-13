function dms = mat2dms (mat, n)
    [deg, min, sec, sig] = mat_parts(mat);
    dms  = sig.*( deg + (min + sec/100)/100 );
end

%!test
%! n = ceil(10*rand);
%! 
%! temp = rand(n,1);
%! sig = ones(n,1);  sig(temp>0.5) = -1;
%! deg = ceil(rand(n,1)*180);
%! min = ceil(rand(n,1)*60);
%! sec = rand(n,1)*60;
%! 
%! idx = sec == 60;  min(idx) = min(idx) + 1;  sec(idx) = 0; 
%! idx = min == 60;  deg(idx) = deg(idx) + 1;  min(idx) = 0; 
%! 
%! deg = sig .* deg;
%! min = sig .* min;
%! sec = sig .* sec;
%! 
%! mat = [deg min sec sig];
%! dms = deg + (min + sec/100)/100;
%! dms2 = mat2dms(mat);
%! 
%! err = dms2 - dms;
%! %idx = err > 1000*eps;
%! %err(idx), [dms(idx), dms2(idx)], [deg(idx), min(idx), sec(idx)]  % DEBUG
%! myassert (err, 0, -1000*eps);

%!test
%! answer = mat2dms ([0 0 60 1], 0);
%! myassert(answer, 0.0060, -sqrt(eps));
%! 
%! answer = mat2dms(mat_normal([0 0 60 1]));
%! myassert(answer, 0.01, -sqrt(eps));

